# Vorbereitungen ---------------------------------------------------------------

# Sicherstellen dass benötigte Packages installiert sind
packages <- c("dplyr", "tidyr", "readxl", "ggplot2", "ggfortify",
              "survival", "scales", "gsDesign")
for (package in packages) {
  if (!require(package, character.only=TRUE)) install.packages(package)
}

# Packages laden
library(dplyr)
library(ggplot2)
library(ggfortify)
library(survival)

# Daten einlesen
df <- readxl::read_xlsx("simulierte_daten_a20.xlsx")

# Status als boolean kodieren
df$status_bool <- df$status == "tot"

# Ggf. Ordner für Abbildungen und Tabellen anlegen
table_and_plot_dir <- "Abbildungen und Tabellen"
if (!dir.exists(table_and_plot_dir)) {dir.create(table_and_plot_dir)}


# Deskriptive Zusammenfassung --------------------------------------------------

# Tabelle
mean_sd <- function(x, mw_digits=2, sd_digits=2) {
  mw = round(mean(x), mw_digits) %>% format(nsmall=mw_digits)
  sa = round(sd(x), sd_digits) %>% format(nsmall=sd_digits)
  return(paste0(mw, " (", sa, ")"))
}

zeit_tabelle <- df %>%
  group_by(Gruppe, status) %>%
  summarize(Zeit = mean_sd(Zeit, mw_digits=1)) %>%
  tidyr::pivot_wider(names_from=status, values_from=Zeit) %>%
  rename("Zensierungszeitpunkt (n=5)" = "lebt",
         "Todeszeitpunkt (n=10)" = "tot")

alter_tabelle <- df %>%
  group_by(Gruppe) %>%
  summarize("Alter (n=15)" = mean_sd(Alter, mw_digits=1))

left_join(zeit_tabelle, alter_tabelle) %>%
  write.csv(file.path(table_and_plot_dir, "deskriptive_tabelle_roh.csv"))

# Boxplot
df %>%
  mutate(status=if_else(status_bool,
                        "Todeszeitpunkt", "Zensierungszeitpunkt")) %>%
  ggplot(aes(x=Gruppe, y=Zeit)) +
    geom_boxplot(outliers=F) +
    theme_bw() +
    geom_dotplot(binaxis = "y", stackdir = "center",
                 dotsize = 0.6, alpha=0.3, stackratio=1.1) +
    scale_y_continuous(breaks=seq(0,16,4)) +
    facet_wrap("status") +
    labs(x=NULL, y="Zeit", title="Todes- bzw. Zensierungszeitpunkte nach Gruppe")

ggsave("Zeit_Boxplot.png", path=table_and_plot_dir,
       width=2000, height=1400, units="px")


# Aufgaben ---------------------------------------------------------------------


# (i) Kaplan-Meier-Schätzer und -Kurven ----------------------------------------

# KM-Schätzer
km_fit <- survfit(Surv(Zeit, status_bool) ~ Gruppe, data=df)
summary(km_fit)

# KM-Kurven
plot_data <- autoplot(km_fit)$data
ggplot(plot_data, aes(x=time, y=surv, group=strata, linetype=strata)) +
  geom_step(alpha=0.9) +
  geom_point(data=subset(plot_data, n.censor > 0),
             aes(shape=strata),
             stroke=1.5,
             alpha=0.5) +
  theme_bw() +
  theme(legend.title=element_blank(),
        legend.position="inside",
        legend.position.inside=c(0.85,0.85),
        legend.background=NULL) +
  scale_shape_manual(values=c(Interventionsgruppe=3, Kontrollgruppe=4)) +
  scale_x_continuous(limits=c(0,14), breaks=seq(0,14,2)) +
  scale_y_continuous(breaks=seq(0,1,0.2), labels=scales::percent) +
  labs(x="Zeit", y="Überlebenswahrscheinlichkeit",
       title="Kaplan-Meier-Kurven nach Gruppe")

ggsave("KM_Plot.png", path=table_and_plot_dir,
       width=2500, height=1500, units="px")


# (ii) Log-Rank-Test -----------------------------------------------------------

# Test
logrank <- survdiff(Surv(Zeit, status_bool) ~ Gruppe, data=df)
logrank

# Power Analysis
cox <- coxph(Surv(Zeit, status_bool) ~ Gruppe, data=df)
hr <- 1/exp(cox$coefficients[[1]])
# Wie im Bericht, Abschnitt 3.2.3: hypothetisch 30 Todesfälle ohne Zensierung.
# n bezeichnet Ereignisse, nicht die Zahl der Teilnehmenden.
gsDesign::nEvents(hr=hr, alpha=0.05, sided=2, n=30, tbl=TRUE) # Power
gsDesign::nEvents(hr=hr, alpha=0.05, sided=2, beta=0.2, tbl=TRUE) # Stichprobe


# (iii) Störgrößen -------------------------------------------------------------

# Boxplots
ggplot(df, aes(x=Gruppe, y=Alter)) +
  geom_boxplot() +
  theme_bw() +
  geom_dotplot(binaxis = "y", stackdir = "center",
               dotsize = 0.6, alpha=0.3, stackratio=1.1) +
  labs(x=NULL, y="Alter (in Jahren)", title="Alter nach Gruppe")

ggsave("Alter_Boxplot.png", path=table_and_plot_dir,
       width=1200, height=1100, units="px")

# Q-Q-Diagramme
ggplot(df, aes(sample=Alter)) +
  geom_qq() +
  geom_qq_line() +
  facet_wrap("Gruppe", scales="free") +
  labs(x="Quantile der Normalverteilung", y="Stichprobenquantile",
       title="Q-Q-Diagramme Alter nach Gruppe") +
  theme_bw()

ggsave("Alter_QQ.png", path=table_and_plot_dir,
       width=3500, height=1500, units="px")

# Wilcoxon-Rangsummen-Test
alter_ig <- df$Alter[df$Gruppe == "Interventionsgruppe"]
alter_kg <- df$Alter[df$Gruppe == "Kontrollgruppe"]
wilcox.test(alter_ig, alter_kg)

# Internship Participation Explorer
# Interactive Shiny app for the self-run STA304 practice project
# "Estimating the Proportion of Students Participating in Internship Opportunities"
# Data: internship_survey.csv (n = 50)

library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(DT)

# ---- Data ------------------------------------------------------------------

raw <- read.csv("internship_survey.csv")

survey <- raw |>
  mutate(
    Gender = factor(gender, levels = 0:2,
                    labels = c("Male", "Female", "Other / Prefer not to say")),
    Status = factor(status, levels = 0:1, labels = c("Domestic", "International")),
    Program = factor(program, levels = 1:5,
                     labels = c("Statistics", "Mathematics", "Computer Science",
                                "Economics / Management", "Other")),
    Coop = factor(coop, levels = 0:1, labels = c("Not in co-op", "In co-op")),
    Internship = factor(had_internship, levels = 0:1,
                        labels = c("No internship", "Had internship")),
    Barrier = factor(main_barrier, levels = 0:5,
                     labels = c("Not applicable", "Lack of relevant experience",
                                "Lack of time", "Work permit / visa restrictions",
                                "Don't know where to look", "Not interested right now"))
  )

# Readable names for every variable the user can pick
group_choices <- c("Co-op enrolment" = "Coop",
                   "Domestic / international" = "Status",
                   "Program of study" = "Program",
                   "Gender" = "Gender")

numeric_choices <- c("Applications in the past 12 months" = "num_applications",
                     "Hours per week spent searching" = "search_hours")

likert_choices <- c("Confidence about securing an internship" = "confidence",
                    "Internships are important for my career" = "importance",
                    "University provides enough support" = "uni_support")

compare_choices <- c("Internship experience" = "Internship",
                     "Co-op enrolment" = "Coop",
                     "Domestic / international" = "Status")

likert_labels <- c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")

label_of <- function(choices, value) names(choices)[choices == value]

# ---- Colour palettes ---------------------------------------------------------

palettes <- list(
  "Colour-blind safe (Okabe-Ito)" = function(n)
    rep_len(c("#0072B2", "#E69F00", "#009E73", "#CC79A7", "#56B4E9",
              "#D55E00", "#F0E442"), n),
  "Harbour blues" = function(n)
    colorRampPalette(c("#0B3C5D", "#328CC1", "#A9D6E5"))(n),
  "Autumn" = function(n)
    colorRampPalette(c("#7F2704", "#F16913", "#FDD0A2"))(n),
  "Viridis" = function(n) hcl.colors(n, "viridis"),
  "Greyscale (print friendly)" = function(n) gray.colors(n, start = 0.15, end = 0.75)
)

# ---- Helpers -----------------------------------------------------------------

fmt_pct <- function(x) paste0(round(100 * x), "%")
fmt_p <- function(p) if (p < 0.001) "p < 0.001" else paste0("p = ", sprintf("%.3f", p))

plot_theme <- theme_minimal(base_size = 15) +
  theme(plot.title = element_text(face = "bold"),
        legend.position = "bottom",
        panel.grid.minor = element_blank())

# ---- UI ----------------------------------------------------------------------

ui <- page_navbar(
  title = "Internship Participation Explorer",
  theme = bs_theme(version = 5, primary = "#2A6F97", secondary = "#E69F00",
                   "navbar-bg" = "#2A6F97"),
  fillable = FALSE,

  sidebar = sidebar(
    width = 290,
    h5("Filter respondents"),
    checkboxGroupInput("status", "Domestic / international",
                       choices = levels(survey$Status),
                       selected = levels(survey$Status)),
    checkboxGroupInput("gender", "Gender",
                       choices = levels(survey$Gender),
                       selected = levels(survey$Gender)),
    checkboxGroupInput("program", "Program of study",
                       choices = levels(survey$Program),
                       selected = levels(survey$Program)),
    sliderInput("apps", "Applications in the past 12 months",
                min = 0, max = max(survey$num_applications),
                value = c(0, max(survey$num_applications)), step = 1),
    actionButton("reset", "Reset filters", class = "btn-outline-primary btn-sm"),
    hr(),
    h5("Appearance"),
    selectInput("palette", "Colour palette", choices = names(palettes)),
    hr(),
    uiOutput("n_selected")
  ),

  # Overview: RQ1
  nav_panel(
    "Overview",
    layout_columns(
      col_widths = c(4, 4, 4),
      value_box(title = "Students in selection", value = textOutput("vb_n")),
      value_box(title = "Have had an internship", value = textOutput("vb_prop"),
                theme = "primary"),
      value_box(title = "95% confidence interval", value = textOutput("vb_ci"))
    ),
    layout_columns(
      col_widths = c(7, 5),
      card(
        card_header("Each square is one student"),
        plotOutput("grid_plot", height = "380px")
      ),
      card(
        card_header("What this means"),
        uiOutput("overview_text")
      )
    )
  ),

  # Who gets internships: RQ2
  nav_panel(
    "Who Gets Internships?",
    layout_columns(
      col_widths = c(8, 4),
      card(
        card_header("Internship participation by group"),
        layout_columns(
          col_widths = c(6, 6),
          selectInput("group_var", "Compare students by", choices = group_choices),
          radioButtons("bar_scale", "Show bars as",
                       choices = c("Percent of group", "Number of students"),
                       inline = TRUE)
        ),
        plotOutput("group_plot", height = "420px")
      ),
      card(
        card_header("Is the difference real?"),
        uiOutput("group_text")
      )
    )
  ),

  # Applications and effort: RQ3
  nav_panel(
    "Applications & Effort",
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("How much effort do students put in?"),
        selectInput("num_var", "Variable", choices = numeric_choices),
        layout_columns(
          col_widths = c(6, 6),
          radioButtons("dist_type", "Plot type",
                       choices = c("Histogram", "Smoothed curves"), inline = TRUE),
          sliderInput("bins", "Number of bars", min = 4, max = 25, value = 10)
        ),
        uiOutput("xrange_ui"),
        checkboxInput("log_x", "Use a log scale on the x-axis", value = FALSE),
        plotOutput("dist_plot", height = "360px")
      ),
      card(
        card_header("Do more applications lead to an internship?"),
        plotOutput("logit_plot", height = "360px"),
        uiOutput("logit_text")
      )
    )
  ),

  # Attitudes: RQ4
  nav_panel(
    "Attitudes",
    layout_columns(
      col_widths = c(8, 4),
      card(
        card_header("How students feel about internships"),
        layout_columns(
          col_widths = c(4, 4, 4),
          selectInput("likert_var", "Statement", choices = likert_choices),
          selectInput("compare_var", "Compare", choices = compare_choices),
          radioButtons("likert_plot", "Plot type",
                       choices = c("Response breakdown", "Box plot"))
        ),
        conditionalPanel(
          "input.likert_plot == 'Box plot'",
          sliderInput("ylim", "Y-axis range (1 = Strongly disagree, 5 = Strongly agree)",
                      min = 1, max = 5, value = c(1, 5), step = 0.5)
        ),
        plotOutput("likert_plot_out", height = "400px")
      ),
      card(
        card_header("Do the groups differ?"),
        uiOutput("likert_text")
      )
    )
  ),

  # Barriers
  nav_panel(
    "Barriers",
    layout_columns(
      col_widths = c(8, 4),
      card(
        card_header("Biggest barrier for students without an internship"),
        checkboxInput("barrier_split",
                      "Compare domestic and international students side by side",
                      value = FALSE),
        plotOutput("barrier_plot", height = "400px")
      ),
      card(
        card_header("What stands out"),
        uiOutput("barrier_text")
      )
    )
  ),

  # Data table
  nav_panel(
    "Data",
    card(
      card_header("Responses in the current selection (sort or search any column)"),
      DTOutput("table")
    )
  ),

  # About
  nav_panel(
    "About",
    card(
      card_header("About this project"),
      markdown("
**Topic.** This app explores what share of STA304H5 students at the University of
Toronto Mississauga have taken part in an internship, and what goes along with
taking part.

**Research questions.**

1. What proportion of students have had an internship? (*Overview* tab)
2. Is participation related to co-op enrolment or domestic/international status? (*Who Gets Internships?*)
3. Do more applications predict getting an internship? (*Applications & Effort*)
4. Do students with internship experience feel more confident? (*Attitudes*)

**Survey design.** An 11-question online questionnaire, with stratified random
sampling by domestic/international status and a target of 50 responses.

**Important caveats.**

- **The data in this app are simulated** for practice. They are not real student responses.
- In a real version of this survey, respondents would choose whether to answer, so the
  sample would not be truly random and may over-represent students interested in internships.
- With 50 students, some groups (international students, small programs, gender
  categories beyond male/female) are small. Results for them are very uncertain.
- This is an observational survey, so it shows associations, not causes.

**Methods used.** One-sample proportion test, chi-square (or Fisher's exact) test of
independence, Welch two-sample t-test, and logistic regression with model selection by AIC.
      ")
    )
  )
)

# ---- Server ------------------------------------------------------------------

server <- function(input, output, session) {

  pal <- function(n) palettes[[input$palette]](n)

  observeEvent(input$reset, {
    updateCheckboxGroupInput(session, "status", selected = levels(survey$Status))
    updateCheckboxGroupInput(session, "gender", selected = levels(survey$Gender))
    updateCheckboxGroupInput(session, "program", selected = levels(survey$Program))
    updateSliderInput(session, "apps", value = c(0, max(survey$num_applications)))
  })

  filtered <- reactive({
    validate(
      need(length(input$status) > 0, "Select at least one domestic/international group."),
      need(length(input$gender) > 0, "Select at least one gender."),
      need(length(input$program) > 0, "Select at least one program.")
    )
    d <- survey |>
      filter(Status %in% input$status,
             Gender %in% input$gender,
             Program %in% input$program,
             num_applications >= input$apps[1],
             num_applications <= input$apps[2])
    validate(need(nrow(d) > 0, "No students match these filters. Try widening them."))
    d
  })

  output$n_selected <- renderUI({
    n <- tryCatch(nrow(filtered()), error = function(e) 0)
    tags$p(tags$strong(n), " of ", nrow(survey), " students selected")
  })

  # ---- Overview ----

  prop_result <- reactive({
    d <- filtered()
    suppressWarnings(prop.test(sum(d$had_internship), nrow(d), p = 0.5))
  })

  output$vb_n <- renderText(nrow(filtered()))
  output$vb_prop <- renderText(fmt_pct(mean(filtered()$had_internship)))
  output$vb_ci <- renderText({
    ci <- prop_result()$conf.int
    paste(fmt_pct(ci[1]), "to", fmt_pct(ci[2]))
  })

  output$grid_plot <- renderPlot({
    d <- filtered() |>
      arrange(desc(Internship)) |>
      mutate(i = row_number() - 1, x = i %% 10, y = -(i %/% 10))
    ggplot(d, aes(x, y, fill = Internship)) +
      geom_tile(width = 0.85, height = 0.85) +
      scale_fill_manual(values = setNames(rev(pal(2)), levels(survey$Internship)),
                        drop = FALSE) +
      coord_equal() +
      labs(title = "Internship experience in the current selection", fill = NULL) +
      theme_void(base_size = 15) +
      theme(legend.position = "bottom", plot.title = element_text(face = "bold"))
  })

  output$overview_text <- renderUI({
    d <- filtered()
    res <- prop_result()
    ci <- res$conf.int
    verdict <- if (res$p.value < 0.05) {
      if (res$estimate > 0.5) "This is clearly more than half of students."
      else "This is clearly less than half of students."
    } else {
      "We can't tell whether the true share is above or below half."
    }
    tagList(
      tags$p(tags$strong(sum(d$had_internship)), " of ", tags$strong(nrow(d)),
             " students in this selection (", fmt_pct(mean(d$had_internship)),
             ") have completed or are currently in an internship."),
      tags$p("Because we only surveyed a sample, the true share across all STA304 students ",
             "is probably somewhere between ", tags$strong(fmt_pct(ci[1])), " and ",
             tags$strong(fmt_pct(ci[2])), ". ", verdict,
             " (Proportion test against 50%: ", fmt_p(res$p.value), ".)"),
      tags$p(class = "text-muted",
             "Smaller selections give wider ranges, because there is less information.")
    )
  })

  # ---- Who gets internships ----

  output$group_plot <- renderPlot({
    var <- input$group_var
    d <- filtered() |> count(Group = .data[[var]], Internship)
    percent <- input$bar_scale == "Percent of group"
    p <- ggplot(d, aes(x = Group, y = n, fill = Internship)) +
      geom_col(position = if (percent) "fill" else "stack", width = 0.7) +
      scale_fill_manual(values = setNames(rev(pal(2)), levels(survey$Internship))) +
      labs(title = paste("Internship participation by", tolower(label_of(group_choices, var))),
           x = label_of(group_choices, var),
           y = if (percent) "Percent of students in group" else "Number of students",
           fill = NULL) +
      plot_theme
    if (percent) p <- p + scale_y_continuous(labels = scales::percent)
    p
  })

  output$group_text <- renderUI({
    var <- input$group_var
    d <- filtered()
    tab <- table(droplevels(d[[var]]), d$Internship)
    validate(need(nrow(tab) >= 2,
                  "The current filters leave only one group, so there is nothing to compare."))

    rates <- d |>
      group_by(Group = droplevels(.data[[var]])) |>
      summarise(rate = mean(had_internship), n = n(), .groups = "drop")
    rate_lines <- lapply(seq_len(nrow(rates)), \(i)
      tags$li(tags$strong(rates$Group[i]), ": ", fmt_pct(rates$rate[i]),
              " (", rates$n[i], " students)"))

    expected_small <- any(suppressWarnings(chisq.test(tab)$expected) < 5)
    if (expected_small) {
      p <- fisher.test(tab)$p.value
      test_name <- "Fisher's exact test (used because some groups are small)"
    } else {
      p <- suppressWarnings(chisq.test(tab))$p.value
      test_name <- "Chi-square test of independence"
    }
    verdict <- if (p < 0.05) {
      "The gap between groups is large enough that it is unlikely to be due to chance alone."
    } else {
      "The gap between groups could easily be due to chance, so we can't conclude that groups truly differ."
    }

    tagList(
      tags$p("Share of students who have had an internship:"),
      tags$ul(rate_lines),
      tags$p(tags$strong(verdict)),
      tags$p(class = "text-muted", test_name, ": ", fmt_p(p), ".")
    )
  })

  # ---- Applications & effort ----

  output$xrange_ui <- renderUI({
    v <- survey[[input$num_var]]
    sliderInput("xrange", "X-axis range", min = 0, max = ceiling(max(v)),
                value = c(0, ceiling(max(v))), step = if (max(v) > 20) 1 else 0.5)
  })

  output$dist_plot <- renderPlot({
    req(input$xrange)
    var <- input$num_var
    d <- filtered()
    cols <- setNames(rev(pal(2)), levels(survey$Internship))
    p <- ggplot(d, aes(x = .data[[var]], fill = Internship))
    p <- if (input$dist_type == "Histogram") {
      p + geom_histogram(bins = input$bins, position = "identity", alpha = 0.65,
                         colour = "white")
    } else {
      p + geom_density(alpha = 0.5, adjust = 1.2)
    }
    p <- p +
      scale_fill_manual(values = cols) +
      labs(title = label_of(numeric_choices, var),
           x = label_of(numeric_choices, var),
           y = if (input$dist_type == "Histogram") "Number of students" else "Relative frequency",
           fill = NULL) +
      plot_theme
    if (input$log_x) {
      p <- p + scale_x_continuous(trans = "log1p") +
        coord_cartesian(xlim = input$xrange)
      p <- p + labs(x = paste(label_of(numeric_choices, var), "(log scale)"))
    } else {
      p <- p + coord_cartesian(xlim = input$xrange)
    }
    p
  })

  logit_fit <- reactive({
    d <- filtered()
    validate(
      need(nrow(d) >= 10, "Select at least 10 students to fit the model."),
      need(length(unique(d$had_internship)) == 2,
           "The selection needs students both with and without internships.")
    )
    glm(had_internship ~ num_applications, data = d, family = binomial)
  })

  output$logit_plot <- renderPlot({
    fit <- logit_fit()
    d <- filtered()
    grid <- data.frame(num_applications = seq(min(d$num_applications),
                                              max(d$num_applications),
                                              length.out = 100))
    pr <- predict(fit, grid, type = "link", se.fit = TRUE)
    grid$prob <- plogis(pr$fit)
    grid$lo <- plogis(pr$fit - 1.96 * pr$se.fit)
    grid$hi <- plogis(pr$fit + 1.96 * pr$se.fit)
    cols <- pal(2)

    ggplot() +
      geom_ribbon(data = grid, aes(num_applications, ymin = lo, ymax = hi),
                  fill = cols[1], alpha = 0.2) +
      geom_line(data = grid, aes(num_applications, prob), colour = cols[1],
                linewidth = 1.3) +
      geom_point(data = d, aes(num_applications, had_internship, colour = Internship),
                 position = position_jitter(width = 0, height = 0.03, seed = 1),
                 size = 3, alpha = 0.75) +
      scale_colour_manual(values = setNames(rev(cols), levels(survey$Internship))) +
      scale_y_continuous(labels = scales::percent, limits = c(-0.06, 1.06)) +
      labs(title = "Chance of having had an internship",
           x = "Applications in the past 12 months",
           y = "Estimated chance", colour = NULL) +
      plot_theme
  })

  output$logit_text <- renderUI({
    fit <- logit_fit()
    s <- summary(fit)$coefficients
    b <- s["num_applications", "Estimate"]
    p <- s["num_applications", "Pr(>|z|)"]
    or5 <- exp(5 * b)
    direction <- if (b > 0) "higher" else "lower"
    verdict <- if (p < 0.05) {
      "This trend is unlikely to be due to chance."
    } else {
      "This trend could be due to chance, so it is not conclusive."
    }
    tagList(
      tags$p("The line shows the estimated chance of having had an internship for a given ",
             "number of applications; the shaded band shows the uncertainty."),
      tags$p("Every 5 extra applications goes with about ",
             tags$strong(paste0(round(abs(or5 - 1) * 100), "% ", direction)),
             " odds of having had an internship. ", verdict,
             tags$span(class = "text-muted", " (Logistic regression, ", fmt_p(p), ".)")),
      tags$p(class = "text-muted",
             "Model selection note: across the full sample, co-op enrolment predicts ",
             "internships better than applications do (it gives the lowest AIC), and once ",
             "co-op is accounted for, applications add little. Co-op and status can't both ",
             "enter the model, because two of their combinations have outcomes that are all ",
             "yes or all no (quasi-complete separation).")
    )
  })

  # ---- Attitudes ----

  output$likert_plot_out <- renderPlot({
    var <- input$likert_var
    grp <- input$compare_var
    d <- filtered()
    title <- paste0("\"", label_of(likert_choices, var), "\" by ",
                    tolower(label_of(compare_choices, grp)))

    if (input$likert_plot == "Box plot") {
      ggplot(d, aes(x = .data[[grp]], y = .data[[var]], fill = .data[[grp]])) +
        geom_boxplot(width = 0.55, alpha = 0.85, show.legend = FALSE) +
        geom_point(position = position_jitter(width = 0.12, height = 0.08, seed = 2),
                   alpha = 0.5, size = 2) +
        scale_fill_manual(values = pal(nlevels(d[[grp]]))) +
        scale_y_continuous(breaks = 1:5, labels = likert_labels) +
        coord_cartesian(ylim = input$ylim) +
        labs(title = title, x = label_of(compare_choices, grp), y = NULL) +
        plot_theme
    } else {
      d |>
        mutate(Response = factor(.data[[var]], levels = 1:5, labels = likert_labels)) |>
        count(Group = .data[[grp]], Response, .drop = FALSE) |>
        ggplot(aes(x = Group, y = n, fill = Response)) +
        geom_col(position = position_fill(reverse = TRUE), width = 0.6) +
        coord_flip() +
        scale_y_continuous(labels = scales::percent) +
        scale_fill_manual(values = pal(5), drop = FALSE) +
        labs(title = title, x = NULL, y = "Percent of students", fill = NULL) +
        plot_theme +
        guides(fill = guide_legend(nrow = 2))
    }
  })

  output$likert_text <- renderUI({
    var <- input$likert_var
    grp <- input$compare_var
    d <- filtered()
    g <- droplevels(d[[grp]])
    validate(need(nlevels(g) == 2,
                  "The current filters leave only one group, so there is nothing to compare."))
    sizes <- table(g)
    validate(need(all(sizes >= 3), "Each group needs at least 3 students to compare."))
    validate(need(all(tapply(d[[var]], g, sd) > 0),
                  "One group gave identical answers, so the test can't be run."))

    lv <- levels(g)
    means <- tapply(d[[var]], g, mean)
    res <- t.test(d[[var]][g == lv[1]], d[[var]][g == lv[2]])
    higher <- names(which.max(means))
    verdict <- if (res$p.value < 0.05) {
      paste0("The \"", higher, "\" group agrees more strongly on average, ",
             "and the difference is unlikely to be due to chance.")
    } else {
      "The difference between the two groups is small enough that it could be due to chance."
    }

    tagList(
      tags$p("Average agreement (1 = Strongly disagree, 5 = Strongly agree):"),
      tags$ul(
        tags$li(tags$strong(lv[1]), ": ", sprintf("%.2f", means[1]), " (", sizes[1], " students)"),
        tags$li(tags$strong(lv[2]), ": ", sprintf("%.2f", means[2]), " (", sizes[2], " students)")
      ),
      tags$p(tags$strong(verdict)),
      tags$p(class = "text-muted", "Welch two-sample t-test: ", fmt_p(res$p.value), "."),
      if (grp == "Internship" && res$p.value < 0.05)
        tags$p(class = "text-muted",
               "This is a survey, so we can't tell whether internships build confidence or ",
               "confident students are more likely to land internships.")
    )
  })

  # ---- Barriers ----

  no_internship <- reactive({
    d <- filtered() |> filter(had_internship == 0) |> mutate(Barrier = droplevels(Barrier))
    validate(need(nrow(d) > 0, "No students without an internship in the current selection."))
    d
  })

  output$barrier_plot <- renderPlot({
    d <- no_internship()
    if (input$barrier_split) {
      d |>
        count(Status, Barrier) |>
        group_by(Status) |>
        mutate(pct = n / sum(n)) |>
        ggplot(aes(x = pct, y = reorder(Barrier, pct), fill = Status)) +
        geom_col(position = position_dodge(preserve = "single"), width = 0.7) +
        scale_fill_manual(values = setNames(pal(2), levels(survey$Status))) +
        scale_x_continuous(labels = scales::percent) +
        labs(title = "Biggest barrier, domestic vs international",
             x = "Percent of students in each group", y = NULL, fill = NULL) +
        plot_theme
    } else {
      d |>
        count(Barrier) |>
        ggplot(aes(x = n, y = reorder(Barrier, n))) +
        geom_segment(aes(x = 0, xend = n, yend = reorder(Barrier, n)),
                     colour = "grey70", linewidth = 1.2) +
        geom_point(size = 6, colour = pal(1)) +
        geom_text(aes(label = n), colour = "white", size = 3.5, fontface = "bold") +
        labs(title = "Biggest barrier to getting an internship",
             x = "Number of students", y = NULL) +
        plot_theme
    }
  })

  output$barrier_text <- renderUI({
    d <- no_internship()
    counts <- sort(table(d$Barrier), decreasing = TRUE)
    top <- names(counts)[1]
    intl <- d |> filter(Status == "International")
    intl_line <- if (nrow(intl) > 0) {
      intl_top <- names(sort(table(droplevels(intl$Barrier)), decreasing = TRUE))[1]
      tags$p("Among international students without an internship, the most common barrier is ",
             tags$strong(tolower(intl_top)), ".")
    }
    tagList(
      tags$p("This tab only includes the ", tags$strong(nrow(d)),
             " selected students who have not had an internship."),
      tags$p("The most common barrier is ", tags$strong(tolower(top)), ", named by ",
             counts[[1]], " students (", fmt_pct(counts[[1]] / nrow(d)), ")."),
      intl_line,
      tags$p(class = "text-muted",
             "Tick the box above the chart to see whether domestic and international ",
             "students face different barriers.")
    )
  })

  # ---- Data table ----

  output$table <- renderDT({
    filtered() |>
      transmute(`#` = respondent, Gender, Status, Program, `Co-op` = Coop, Internship,
                `Applications (12 mo)` = num_applications,
                `Search hours / week` = search_hours,
                Confidence = confidence, Importance = importance,
                `University support` = uni_support,
                `Main barrier` = Barrier) |>
      datatable(rownames = FALSE, filter = "top",
                options = list(pageLength = 10, scrollX = TRUE))
  })
}

shinyApp(ui, server)

# Internship Participation Explorer

Self-run project following the STA304H5 checkpoints: *Estimating the Proportion of Students Participating in Internship Opportunities*. **All data are simulated.**

**Live app:** _paste your Posit Connect Cloud URL here after deploying_

## Files

| File | What it is |
|---|---|
| `proposal.md` | Checkpoint 1: research questions, sampling plan, tests, questionnaire |
| `internship_survey_simulated.csv` | Checkpoint 2: the dataset (50 simulated responses) |
| `codebook.md` | Checkpoint 2: definitions of every variable and value |
| `eda_report.qmd` | Checkpoint 3: exploratory data analysis (render to PDF with Quarto) |
| `app.R` | Checkpoint 4: the Shiny app |

## Running locally

1. Install the packages once in R:

   ```r
   install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "DT",
                      "tidyverse", "easystats", "knitr", "rsconnect"))
   ```

2. Open `app.R` in RStudio and click **Run App**.
3. To build the EDA report, open `eda_report.qmd` and click **Render** (needs Quarto and a LaTeX install such as `tinytex::install_tinytex()`).

## Deploying to Posit Connect Cloud

1. In R, with the working directory set to this folder, create the manifest Connect Cloud needs:

   ```r
   rsconnect::writeManifest(appFiles = c("app.R", "internship_survey_simulated.csv"))
   ```

2. Push everything (including `manifest.json`) to a **public** GitHub repository.
3. Go to <https://connect.posit.cloud>, sign in with GitHub, click **Publish → Shiny**, and choose the repository, branch `main`, and primary file `app.R`.
4. Watch the build log. When it finishes, open the public URL in a private/incognito window and click through every tab and control.
5. Paste the URL at the top of this README and commit.

# Codebook: Internship Participation Survey

**File:** `internship_survey.csv` · 50 rows (one per respondent) · 12 columns

| Variable | Description | Values |
|---|---|---|
| `respondent` | Row identifier | Whole number, 1–50 |
| `gender` | Respondent's gender | 0 = Male, 1 = Female, 2 = Other / Prefer not to disclose |
| `status` | Domestic or international student | 0 = Domestic, 1 = International |
| `program` | Main program of study | 1 = Statistics, 2 = Mathematics, 3 = Computer Science, 4 = Economics / Management, 5 = Other |
| `coop` | Enrolled in a co-op program | 0 = No, 1 = Yes |
| `had_internship` | Has completed, or is currently in, an internship | 0 = No, 1 = Yes |
| `num_applications` | Number of internship applications submitted in the past 12 months | Whole number ≥ 0 |
| `search_hours` | Average hours per week spent on the internship search (applications, networking, interview prep) | Number ≥ 0, one decimal place |
| `confidence` | Agreement with: "I feel confident that I can secure an internship before I graduate." | 1 = Strongly disagree, 2 = Disagree, 3 = Neutral, 4 = Agree, 5 = Strongly agree |
| `importance` | Agreement with: "Completing an internship is important for my career goals." | 1 = Strongly disagree, 2 = Disagree, 3 = Neutral, 4 = Agree, 5 = Strongly agree |
| `uni_support` | Agreement with: "My university provides enough support for finding internships." | 1 = Strongly disagree, 2 = Disagree, 3 = Neutral, 4 = Agree, 5 = Strongly agree |
| `main_barrier` | Biggest barrier to getting an internship | 0 = Not applicable (already had one), 1 = Lack of relevant experience, 2 = Lack of time, 3 = Work permit / visa restrictions, 4 = Don't know where to look, 5 = Not interested right now |

## Notes

- No missing values.
- `main_barrier` is 0 for every respondent with `had_internship = 1`. Filter those out when analyzing barriers.
- Likert items are stored as numbers, so they can be averaged or compared directly in R.

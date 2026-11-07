# Proposal: Estimating the Proportion of Students Participating in Internship Opportunities

*Self-run project following the STA304H5 checkpoints.*

## Research Questions

- **RQ1.** What proportion of STA304H5 students have completed, or are currently in, an internship?
- **RQ2.** Is internship participation associated with co-op enrolment or with domestic/international status?
- **RQ3.** Which factors (number of applications, co-op enrolment, domestic/international status) best predict whether a student has had an internship?
- **RQ4.** Do students who have had an internship feel more confident about securing one than students who have not?

## Target Population

All students enrolled in STA304H5 (Surveys, Sampling and Observational Data) at the University of Toronto Mississauga in Fall 2026.

## Sampling Method

**Stratified random sampling**, with two strata: domestic and international students. International students may face work-permit limits on internships, so stratifying guarantees enough of them in the sample to compare the two groups. Within each stratum, respondents are selected at random, with a target of 50 responses in total, allocated roughly in proportion to stratum size.

## Data Collection

The questionnaire would be built in Google Forms and shared through the course discussion board and in tutorials.

## Statistical Methods

**Simple tests**

- **One-sample proportion test and 95% confidence interval (RQ1):** estimates the participation rate and tests it against 50%.
- **Chi-square test of independence (RQ2):** tests whether participation is associated with co-op enrolment and with domestic/international status.
- **Welch two-sample t-test (RQ4):** compares mean confidence (1–5 Likert) between students with and without internship experience.

**Advanced test**

- **Logistic regression with model selection (RQ3):** models the probability of having had an internship using number of applications, co-op enrolment, and status. Candidate models are compared using AIC to choose the best set of predictors.

## Questionnaire

1. What is your gender? (Male / Female / Other / Prefer not to disclose)
2. Are you a domestic or international student?
3. What is your main program of study? (Statistics / Mathematics / Computer Science / Economics or Management / Other)
4. Are you enrolled in a co-op program? (Yes / No)
5. Have you completed, or are you currently in, an internship? (Yes / No)
6. How many internship applications have you submitted in the past 12 months?
7. On average, how many hours per week do you spend on your internship search?
8. How do you feel about this statement: "I feel confident that I can secure an internship before I graduate." (Strongly disagree / Disagree / Neutral / Agree / Strongly agree)
9. How do you feel about this statement: "Completing an internship is important for my career goals." (same scale)
10. How do you feel about this statement: "My university provides enough support for finding internships." (same scale)
11. What is the biggest barrier to getting an internship? (Lack of relevant experience / Lack of time / Work permit or visa restrictions / Don't know where to look / Not interested right now)

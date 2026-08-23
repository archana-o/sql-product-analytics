# Activation Curve: Time-to-First-Meaningful-Action

##  What does this SQL do?

This analysis measures **how quickly new signups become meaningful users** and how 7-day activation changes across signup cohorts.

A **meaningful action** is defined as the first occurrence of:

- `add_to_cart`
- `begin_checkout`
- `purchase`

A user is considered **activated** if they take their first meaningful action within **7 days (10,080 minutes)** of signup.

The output shows:

- **`signup_week`** — The week in which the customer signed up.
- **`cohort_size`** — Total number of customers who signed up during that week.
- **`activated_7d`** — Number of customers who took their first meaningful action within 7 days.
- **`activation_rate_7d`** — Percentage of the cohort that activated within 7 days.
- **`median_minutes_to_activation`** — Median time taken by 7-day activators to take their first meaningful action.
- **`p90_minutes_to_activation`** — Time within which 90% of 7-day activators took their first meaningful action.

---

##  Pattern Choice

The query uses **two CTEs**:

### CTE 1 — `signup_cohort`

This CTE creates the weekly signup cohorts and calculates the number of customers in each cohort.

It applies the **2026-04-19 instrumentation cutoff**, because session-event tracking was not available before this date. Therefore, customers who signed up before the instrumentation launch are excluded from the analysis.

### CTE 2 — `first_action`

This CTE identifies each customer's **first meaningful action** after signup.

It calculates the time between signup and the first meaningful action in minutes.

Events occurring before the customer's signup time are excluded to prevent negative activation times.

The final query then aggregates these customer-level results by signup week to calculate 7-day activation and activation-time metrics.

---

## 3. Business Interpretation

### Overall Activation Trend

The results show that 7-day activation **improved across the earlier cohorts**, increasing from:

- **15.31%** for the April 20 cohort
- **21.67%** for the May 18 cohort

This suggests that customers in the May cohorts were more likely to take a meaningful action within their first 7 days compared with the earlier April cohorts.

However, activation declined afterward:

- **15.71%** on May 25
- **13.20%** on June 1
- **8.79%** on June 8

The June 8 cohort should be interpreted cautiously because the most recent cohort may not have had a complete 7-day observation window. Therefore, the lower activation rate may be partly caused by **incomplete observation time**, rather than a genuine decline in customer activation.

### Activation Timing

The median time to activation for the cohorts is generally around **4,000–4,600 minutes**, which is approximately **2.8–3.2 days**.

This means that among customers who activate within 7 days, a typical customer takes roughly **3 days** to perform their first meaningful action.

The p90 values are generally around **8,000–9,000 minutes**, or approximately **5.5–6.3 days**.

This indicates that most 7-day activators complete their first meaningful action within the first week, although some customers take several days before becoming active.

---

## 4. What I Would Investigate Next

1. **Investigate the drop in activation after May 18.**  
   Check whether there were changes in the product experience, onboarding, traffic sources, pricing, campaigns, or other factors that could explain the decline.

2. **Analyze activation by acquisition source.**  
   Compare activation rates across marketing channels, campaigns, and promotions to identify which sources bring customers who activate faster.

3. **Analyze activation by customer and product segments.**  
   Break down 7-day activation by customer segment, product, and category to identify which groups have stronger or weaker activation.

---


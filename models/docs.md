{% docs __overview__ %}

# Pharma Analytics dbt Project

This project transforms raw pharmaceutical data into analytics-ready models
for a pharmaceutical company's data team.

## Data Sources
- **Prescriptions**: Daily prescription fill records from pharmacy claims
- **Adverse Events**: FDA-style adverse event reporting (FAERS)
- **Clinical Trials**: Trial registry and enrollment tracking
- **Inventory**: Warehouse stock levels and supply chain data
- **Sales**: Territory and rep performance metrics

## Model Layers
| Layer | Purpose | Materialization |
|-------|---------|----------------|
| **Staging** | Source-conformed, cleaned data | View |
| **Intermediate** | Business logic joins | Ephemeral |
| **Marts** | Business-facing dimensions and facts | Table |

## Key Metrics
- **Total Rx Volume**: Count of prescription fills
- **New-to-Brand (NTB)**: First-time prescriptions for a drug
- **Adverse Event Rate**: Events per drug per time period
- **Trial Enrollment %**: Actual vs target enrollment

{% enddocs %}


{% docs ndc_code %}
The National Drug Code (NDC) is a unique 10-digit or 11-digit identifier
assigned to each medication listed under Section 510 of the US Federal Food,
Drug, and Cosmetic Act. Format: labeler-product-package.
{% enddocs %}


{% docs therapeutic_class %}
Therapeutic class categorizes drugs by the condition they treat.
Used for portfolio analysis and commercial reporting.

| Code | Class |
|------|-------|
| ENDO | Endocrinology |
| CARD | Cardiology |
| ONCO | Oncology |
| IMMU | Immunology |
| RESP | Respiratory |
| ANTI | Anti-Infective |
{% enddocs %}

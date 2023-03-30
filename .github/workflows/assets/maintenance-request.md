---
name: Maintenance Request
about: Request a change to Lab/Sandbox or the Production environment.
title: __mr_summary__ (YYYY/MM/DD HH:MM ET)
labels: maintenance-request
assignees: lighthouse-leeroyjenkles
---

# MAINTENANCE REQUEST

⚠️ **Attention: If this application is being deployed in an SLA environment for the first time:**

> - [ ] I certify this application is compliant with the [SLA Environment Requirements for Applications](https://community.max.gov/display/VAExternal/SLA+Environment+Requirements+for+Applications) guidelines, including having a completed Fortify/CompositionAnalysis and WASA (if applicable).

---

_This request was auto-generated. Please only approve this MR if the time is correct in the title as the deploy timing with be automated based off that and the approved label being applied._

```
Environment ... dvp-production
Product ....... platform-backend
Start ......... __proposed_start_date_time__
End ........... __proposed_end_date_time__
```

**SLA OR PERFORMANCE IMPACTS**

<!-- Is this change expected to temporarily cause product outages or impact its performance? Enter "N/A" if not applicable. -->

- N/A

**WHAT MAINTAINERS SEE NOW VS AFTER**

<!-- Describe the initial state vs the final state of the product after the updates. For an application, this could be current version vs future version. -->

MAINTAINER_NOTES

**WHAT USERS SEE NOW VS AFTER**

<!-- Describe how this maintenance will impact end-users of the product. -->

- N/A

**DEPLOYMENT PROCEDURE**

<!-- List the deployment steps you will follow in this MR. -->

1. [https://tools.health.dev-developer.va.gov/jenkins/job/department-of-veterans-affairs/job/health-apis-deployer/job/d2/](https://tools.health.dev-developer.va.gov/jenkins/job/department-of-veterans-affairs/job/health-apis-deployer/job/d2/)
2. Build with parameters

**ROLLBACK PROCEDURE**

<!-- List the rollback steps you will follow in this MR. -->

1. Push a change to main branch that reverts the latest changes and re-deploy

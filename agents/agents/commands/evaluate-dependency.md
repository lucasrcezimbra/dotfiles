---
name: "Evaluate Dependency"
description: "Discuss to evaluate a dependency."
---

## Notes
- If the dependency supports more than one language, prefer Python.
- If you need to explore the codebase of the dependency, just clone it in /tmp and explore. Don't use GitHub CLI to navigate the code.
- This should be a back and forth. Do a evaluation based on the topics below and wait for user input to explore more.
- If the docs have a section answering one of the evaluations, point to it as reference.

## Evaluations
### Comparison (direct)
- What are the other options?
- Compare pros and cons of each one
- What are the killing features of each one?
- Include code examples of each one showing how to do the same in the different options.
- Include the best use cases for each one of the options.

### Comparison (indirect)
- Compare with options that have different purpose. For example, I'm evaluating Redis for caching, but we could use a database for caching, too.
- Include why I should consider these other options.
- Include the best use cases for each one of the options.

### Community
- How widely adopted is it?
- Is it actively maintained?

### Infrastructure
- Does it depends on any infrastructure? e.g. database, caching, queues, etc.

### License
- Is it open-source?
- What is the license?
- Does it have a paid version?

### Lock-in
- How hard is to move out of it?
- How hard is to migrate to the others option from Comparison?
- Is this a one-way or two-way door decision?

### Misc
- Is there a company behind it? What are their incentives to support it?

### Stability
- Is it actively maintained?
- Is it is a production-ready state?

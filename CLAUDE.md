# Claude

## Git Commits

Write a clear and concise git commit message for the currently-staged changes (comparing against HEAD), obeying the following rules.

- Plain text only, no markup language
- Separate subject from body with a blank line
- Limit the subject line to 40 characters max
- Capitalize the subject line
- Do not end the subject line with a period
- Use the imperative mood in the subject line
- Wrap the body at 72 characters
- Write the body as a bullet list, one item per change
- Use the body to explain what and why, not how
- Mention all non-formatting changes
- If the only changes are whitespace or line breaks: `Reformat code`
- Don't write for each single commit that is authored with Claude

The subject line is required. The body is optional, and should be omitted if the subject line is self-explanatory (e.g. `Fix typo in user guide`). Mention any modified existing functionality or newly added tests.

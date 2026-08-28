# Claude

## Write a Git commit message

Write a clear and concise git commit message for the currently-staged changes (comparing against HEAD), obeying the following rules.

- The message should be plain text, with no use of any markup language
- Separate subject from body with a blank line
- Limit the subject line to a maximum of 40 characters
- Capitalize the subject line
- Do not end the subject line with a period
- Use the imperative mood in the subject line
- Wrap the body at 72 characters
- If there are multiple paragraphs in the body they should be separated by one blank line
- Use the body to explain what and why rather than how
- Make sure that all non-formatting changes are mentioned.
- If the only changes are changed in whitespace and line breaks, the commit message should be one line: "Reformat code"
- Do not mention Claude in the commit message

The subject line is required. The body is optional, and should be omitted if the subject line explains the commit sufficiently well, e.g.: "Fix type in introduction to user guide". If existing functionality has been modified, make sure to mention it. If new testing has been added, make sure to mention it.
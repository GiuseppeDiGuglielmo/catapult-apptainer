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
## Add support for a new Catapult release

Do this whenever a new directory appears under doc/siemens/<version>/ with the
Siemens documents (catapult_install.pdf, catapult_relnotes.pdf,
release_highlights.pdf; PDFs are gitignored and stay untracked).

1. Create the branch ver-<version> from the branch of the most recent
   previous release, not from main (e.g. ver-2026.3_1 from ver-2026.3), so
   earlier image fixes and this procedure carry forward. If the current
   checkout has uncommitted changes, work in a git worktree and leave them
   alone.
2. Extract the text with `pdftotext -layout` into the scratchpad and compare
   it with the previous release's documents (e.g.
   `git diff --no-index --word-diff`). Check at least:
   - Release notes "Platform Compatibility": OS, 32-bit mode.
   - Release notes "License Daemon Requirements" and install manual
     chapter 1: saltd version, License Server version, FlexNet directory.
   - Release notes "Software Compatibility" table and its change list.
   - The release's Enhancements and Option Changes, for new OS dependencies.
   - "Known Problems and Workarounds".
3. Write doc/siemens/<version>/README.md, following the previous release's
   README: summary of changes since the previous release, operating system,
   32-bit runtime, licensing, toolchain shipped with Catapult, OS packages per
   flow, third-party compatibility (bold marks changes), image changes, and
   host updates. Record contradictions between the Siemens documents instead
   of silently picking one.
4. Change containers/apptainer_catapult_rocky.def only for packages the
   documentation requires and the image lacks; commit that separately and
   list the additions in the README.
5. Update templates/siemens.sh: CATAPULT_VER and the suggested
   QUESTASIM_VER.
6. Check the host: whether the release and the qualified QuestaSim are
   installed under TOOLS_DIR, and what ~/bin/siemens.sh points at.
7. Commit following the commit message rules above. Push only when asked,
   with `git push -u origin ver-<version>`.
8. Finish with a report to the user in two parts, and keep the same content
   in the README's "Image changes" and "Host updates" sections:
   - Linux image: what was added to the definition file and why, or that
     nothing was, and whether the image needs a rebuild.
   - Host: what to install or update (Catapult, ~/bin/siemens.sh, TOOLS_DIR,
     QuestaSim/Visualizer, license server, third-party tools whose qualified
     versions changed), split into required, flow-dependent, recommended,
     and optional, plus anything to verify after installing.

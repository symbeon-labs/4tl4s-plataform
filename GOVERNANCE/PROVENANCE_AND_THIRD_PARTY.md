# Provenance and Third-Party Reuse Controls

## Purpose

This policy establishes a review path for code, documentation, designs, models, datasets, and other materials considered for use in 4TL4S.

## No automatic inheritance

4TL4S does not automatically inherit code, documentation, data, design assets, or rights from another Symbeon repository or project. Every imported or adapted asset must have a recorded source and rights basis.

## Existing Mission Control repository

The earlier `symbeon-mission-control` repository was identified as declaring the MIT License. Before copying or adapting any of its implementation:

1. inspect the exact license file and relevant notices at the source revision;
2. identify the files and dependencies proposed for reuse;
3. preserve required copyright and license notices;
4. record source repository, commit, file paths, and modifications;
5. review third-party dependencies and embedded assets separately;
6. record the decision and reviewer in the provenance register.

The existence of an MIT license does not remove the need to preserve notices or review third-party materials. This policy does not assert that any code from that repository has already been imported into 4TL4S.

## Required provenance record

For each reused or imported asset, record:
- asset identifier and description;
- source repository, URL, version or commit, and file path;
- original author or copyright notice where known;
- license or contractual rights basis;
- modifications and derivative relationship;
- dependencies and their licenses;
- intended use and distribution scope;
- review status, reviewer, and date.

## Unknown or conflicting rights

If the source, license, contributor rights, or client restrictions are unknown or conflicting, do not import, publish, sublicense, or commercialize the asset until reviewed.

## Client materials

Client-provided data, documents, code, credentials, and confidential information must not be copied into shared Symbeon assets or unrelated initiatives without an explicit rights basis and authorization.

## Status

This is an internal governance requirement, not a legal opinion or a substitute for review of the applicable license, contract, or law.

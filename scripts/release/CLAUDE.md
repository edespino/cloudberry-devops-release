# Apache Cloudberry Release Script - Claude Context

## Overview
This directory contains `cloudberry-release.sh`, an automated release utility for Apache Cloudberry (Incubating) that handles both release candidate (RC) staging and final release creation.

## Script Capabilities

### Core Features
- **Version Validation**: Checks consistency across `configure.ac`, `configure`, `gpversion.py`, and `pom.xml`
- **Git Tag Management**: Creates and validates both RC and final release tags
- **Source Tarball Generation**: Creates properly structured source archives
- **Cryptographic Security**: Generates SHA-512 checksums and GPG signatures
- **Submodule Support**: Recursively archives all Git submodules
- **Artifact Verification**: Validates integrity and authenticity of generated artifacts

### Two Main Workflows

#### 1. Release Candidate Staging (`--stage`)
```bash
./cloudberry-release.sh --stage --tag 2.0.0-incubating-rc1 --gpg-user your@apache.org
```
- Creates RC tag (e.g., `2.0.0-incubating-rc1`)
- Generates RC tarball with RC suffix in name and directory structure
- Creates SHA-512 checksum and GPG signature
- Moves artifacts to `~/artifacts/` directory (relative to repository location)

#### 2. Final Release Creation (`--release`)
```bash
./cloudberry-release.sh --release --tag 2.0.0-incubating-rc1 --gpg-user your@apache.org
```
- Takes an existing RC tag as input
- Creates final release tag by removing `-rc#` suffix (e.g., `2.0.0-incubating`)
- Generates clean final release tarball without RC references
- Creates new SHA-512 checksum and GPG signature for final artifacts
- Follows Apache best practices for immutable release artifacts

## Command Line Options

| Option | Description |
|--------|-------------|
| `-s, --stage` | Stage a release candidate and generate source tarball |
| `-R, --release` | Create final release from RC tag (creates final tag and tarball) |
| `-t, --tag <tag>` | Tag to apply or validate (required with --stage or --release) |
| `-f, --force-tag-reuse` | Allow reuse of existing tag if it matches current HEAD |
| `-r, --repo <path>` | Optional path to local Cloudberry Git repository |
| `-S, --skip-remote-check` | Skip validation of remote.origin.url |
| `-g, --gpg-user <key>` | GPG key ID or email for signing (required unless --skip-signing) |
| `-k, --skip-signing` | Skip GPG key validation and signature generation |
| `-h, --help` | Show usage information |

## Key Validations

### Prerequisites
- Must be run from Cloudberry Git repository root or use `--repo` path
- Git `user.name` and `user.email` must be configured
- Repository remote should be `git@github.com:apache/cloudberry.git` (can skip with `-S`)
- Working tree must be clean
- All Git submodules must be initialized

### Version Consistency Checks
- `configure.ac` version matches expected format
- Generated `configure` script version is up-to-date
- `gpversion.py` MAIN_VERSION matches major version pattern `[X,99]`
- `pom.xml` version consistency with tag (accounting for RC vs final differences)

### Tag Validation
- RC tags must match pattern: `X.Y.Z-incubating-rcN`
- Final tags must match pattern: `X.Y.Z-incubating`
- Major version must match `configure.ac`

## File Structure

### Generated Artifacts
Artifacts are created in `~/artifacts/` directory (relative to the repository location):
```
~/artifacts/
├── apache-cloudberry-X.Y.Z-incubating-rcN-src.tar.gz      # RC tarball
├── apache-cloudberry-X.Y.Z-incubating-rcN-src.tar.gz.sha512
├── apache-cloudberry-X.Y.Z-incubating-rcN-src.tar.gz.asc
├── apache-cloudberry-X.Y.Z-incubating-src.tar.gz          # Final release tarball
├── apache-cloudberry-X.Y.Z-incubating-src.tar.gz.sha512
└── apache-cloudberry-X.Y.Z-incubating-src.tar.gz.asc
```

### Tarball Internal Structure
- RC: `apache-cloudberry-X.Y.Z-incubating-rcN/`
- Final: `apache-cloudberry-X.Y.Z-incubating/`

## Important Notes

### Apache Incubator Compliance
- Follows Apache Software Foundation release practices
- Creates immutable, signed artifacts for distribution
- Maintains clear separation between RC and final release artifacts
- Supports required cryptographic verification (SHA-512 + GPG)

### Security Considerations
- GPG key validation before signing
- Working tree cleanliness verification
- Remote repository URL validation (prevents accidental releases from forks)
- Artifact integrity verification after generation

### Interactive Requirements
- **GPG Signing**: The script requires interactive passphrase input for GPG signing
- **Confirmations**: User confirmation is required before creating tags
- **Manual Execution**: Script cannot be fully automated with pipes (e.g., `echo "y" |`) due to GPG passphrase requirements
- For automated testing, use `--skip-signing` to bypass GPG interaction

### Development Context
- Added `--release` functionality to support final release creation from RC tags
- Fixed artifacts directory path to use correct location relative to repository
- Fixed release flow logic to properly handle final tag creation from RC tags
- Fixed syntax error with missing `fi` statement in release conditional block
- Enhanced help text and documentation for both workflows
- Maintains backward compatibility with existing `--stage` workflow

## Common Usage Patterns

### Full Release Cycle
```bash
# 1. Create RC
./cloudberry-release.sh --stage --tag 2.0.0-incubating-rc1 --gpg-user your@apache.org

# 2. After RC approval, create final release (requires --force-tag-reuse if RC tag exists)
./cloudberry-release.sh --release --tag 2.0.0-incubating-rc1 --gpg-user your@apache.org --force-tag-reuse
```

### Development/Testing
```bash
# Skip signing for testing
./cloudberry-release.sh --stage --tag 2.0.0-incubating-rc1 --skip-signing

# Work with forks
./cloudberry-release.sh --stage --tag 2.0.0-incubating-rc1 --skip-remote-check --gpg-user your@apache.org
```

## Error Handling
- Comprehensive validation with clear error messages
- Prevents common mistakes (wrong tag formats, missing prerequisites)
- Safe failure modes (no partial state corruption)
- Proper cleanup of temporary directories

## Dependencies
- `git` (with proper configuration)
- `gpg` (for signing, unless `--skip-signing`)
- `xmllint` (for pom.xml parsing)
- `shasum` (for SHA-512 generation)
- `tar`, `gzip` (for tarball creation)

This script is the authoritative tool for Apache Cloudberry release management and follows ASF best practices for incubator projects.
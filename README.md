# CTGLab Website

Official repository for the Computational and Translational Genomics Laboratory website (`ctglab.github.io`), built using the **Hugo** static site generator and the customized **Timer Hugo** theme.

## Prerequisites

To build, preview, and maintain this website locally, ensure you have the following installed:

- **Hugo** (Extended version): `v0.167.0` or higher.
  - Check version: `hugo version`
  - Install via Homebrew (macOS): `brew install hugo`
- **Python 3.x** (for DOI parsing and publication metadata scripts)
  - Required package: `pip install requests`
- **Bash** (for asset auditing, site verification, and WebP image conversion scripts)

## Local Development Setup

Follow these steps to set up and run the project locally:

### 1. Fork and Clone the Repository

If you are contributing, create a fork of this repository on GitHub first. Then, clone the repository to your local machine:

```bash
git clone https://github.com/ctglab/ctglab.github.io.git
cd ctglab.github.io
```

If you are working from your own fork, replace the repository URL accordingly:

```bash
git clone https://github.com/YOUR-USERNAME/ctglab.github.io-fork.git
cd ctglab.github.io-fork
```

### 2. Run the Development Server

Start the Hugo local development server with draft content enabled:

```bash
hugo server -D
```

Once the server is running, open your web browser and navigate to:
`http://localhost:1313/`

## Repository Structure

- `content/`: Markdown files (`.md`) containing publications, pages, and main site sections.
- `data/`: Structured YAML data files (team members, collaborators, funded projects, and tools).
- `layouts/`: Custom HTML templates that modify or extend the default theme structure.
- `static/`: Global static assets (images, documents, and media). Main images are optimized in WebP format within `static/images/`.
- `themes/timer-hugo/`: Base visual theme directory.
- `config.toml`: Main Hugo project configuration file.
- `netlify.toml`: Automated deployment configuration for Netlify.

## Automation and Maintenance Tools

The repository includes custom scripts designed to streamline technical maintenance:

- **`parse_doi.py`**: Python script that fetches publication metadata via DOI, updates `DOI_list.json`, and sorts entries chronologically from newest to oldest.
- **`convert_to_webp.sh`**: Mass-converts images in the static directory to WebP format, removes legacy formats, and updates references across project files.
- **`audit_unused.sh`**: Audit utility that scans project files to detect potential orphaned or unused graphic assets.
- **`check_and_fix_hugo.sh`**: Diagnostic and repair script that verifies template syntax, fixes common formatting issues, and ensures Hugo compatibility.

### Running the Scripts

If you encounter a permission error when executing the Bash scripts, grant execution permissions or invoke them directly through the shell:

```bash
# Option 1: Grant execution permissions
chmod +x convert_to_webp.sh audit_unused.sh check_and_fix_hugo.sh

# Option 2: Execute directly using the interpreter
python3 content/publications/parse_doi.py
bash convert_to_webp.sh
bash audit_unused.sh
bash check_and_fix_hugo.sh
```

## Deployment

The website is configured to compile and deploy automatically via continuous integration (CI/CD) on Netlify and GitHub Pages upon pushing changes to the `main` branch.
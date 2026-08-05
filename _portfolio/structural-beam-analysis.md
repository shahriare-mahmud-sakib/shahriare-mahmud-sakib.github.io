---
layout: project
title: "Structural Beam Analysis with MATLAB"
permalink: /projects/structural-beam-analysis/

# Set this to true to show the project on /projects/.
show_on_projects: true

# Smaller numbers appear first on the Projects page.
order: 1

# Used by the filter buttons. Suggested values:
# academic, professional, research, programming
filter: "academic"

project_type: "Academic Project"
status: "Completed"
period: "Undergraduate project"
discipline: "Structural Engineering"
course: "MATLAB-based structural analysis project"
role: "Project contributor"

cover_image: "/images/projects/structural-beam-analysis/cover.svg"
cover_alt: "Illustration of a loaded structural beam and response diagrams"

summary: >-
  A MATLAB educational tool for analysing cantilever and simply supported beams
  under point loads, uniformly distributed loads, and triangular distributed
  loads. The program produces axial-force, shear-force, bending-moment, and
  deflection diagrams.

tools:
  - "MATLAB"
  - "Structural Analysis"
  - "Numerical Computation"
  - "Beam Theory"
  - "Engineering Visualization"

keywords:
  - "cantilever beam"
  - "simply supported beam"
  - "point load"
  - "uniformly distributed load"
  - "triangular load"
  - "AFD"
  - "SFD"
  - "BMD"
  - "deflection"

links:
  - label: "View MATLAB Code"
    url: "https://github.com/shahriare-mahmud-sakib/structural-beam-analysis"
    icon: "fab fa-github"
    external: true

  # EXAMPLE: Add your report PDF after placing it in files/projects/.
  # - label: "Download Project Report"
  #   url: "/files/projects/structural-beam-analysis/project-report.pdf"
  #   icon: "fas fa-file-pdf"
  #   external: false
  #   download: false

gallery:
  # Replace these SVG placeholders with screenshots of your actual MATLAB plots.
  - image: "/images/projects/structural-beam-analysis/afd-placeholder.svg"
    alt: "Illustrative placeholder for an axial force diagram"
    caption: "Axial Force Diagram — illustrative placeholder; replace with your actual MATLAB output."

  - image: "/images/projects/structural-beam-analysis/sfd-placeholder.svg"
    alt: "Illustrative placeholder for a shear force diagram"
    caption: "Shear Force Diagram — illustrative placeholder; replace with your actual MATLAB output."

  - image: "/images/projects/structural-beam-analysis/bmd-placeholder.svg"
    alt: "Illustrative placeholder for a bending moment diagram"
    caption: "Bending Moment Diagram — illustrative placeholder; replace with your actual MATLAB output."

  - image: "/images/projects/structural-beam-analysis/deflection-placeholder.svg"
    alt: "Illustrative placeholder for a beam deflection diagram"
    caption: "Deflection Diagram — illustrative placeholder; replace with your actual MATLAB output."
---

## Project overview

This project applies MATLAB programming to classical structural-beam analysis. It
supports **cantilever** and **simply supported** beams subjected to point loads,
uniformly distributed loads, and triangular distributed loads.

The program is intended as an educational tool for Civil Engineering students.
It combines structural-analysis calculations with clear visual output so users
can compare loading conditions with the resulting internal-force and deflection
diagrams.

## Main capabilities

- Accepts common beam-support and loading configurations.
- Determines reactions and structural response along the beam.
- Produces the **Axial Force Diagram (AFD)**.
- Produces the **Shear Force Diagram (SFD)**.
- Produces the **Bending Moment Diagram (BMD)**.
- Produces the **Deflection Diagram**.
- Provides a visual workflow that supports teaching and verification.

## Computational workflow

1. Define the beam type, span, material, section properties, and loading.
2. Calculate support reactions.
3. Evaluate internal-force functions along the beam.
4. Calculate displacement or deflection response.
5. Plot the structural-response diagrams in MATLAB.

## Running the project

Clone or download the GitHub repository, place all MATLAB files in one folder,
and run:

```matlab
BeamAnalysisProject
```

The supporting MATLAB files must remain in the same project directory.

## Add your real outputs here

Replace the placeholder images inside:

```text
images/projects/structural-beam-analysis/
```

Recommended filenames:

```text
afd.png
sfd.png
bmd.png
deflection.png
```

Then update the `gallery:` image paths in this file. You can use PNG, JPG, WebP,
or SVG files.

## Add selected code or explanation

You may add short MATLAB code excerpts using fenced code blocks:

```matlab
% Example: call your main analysis workflow
BeamAnalysisProject
```

For the complete source code, use the GitHub button at the top of this page.

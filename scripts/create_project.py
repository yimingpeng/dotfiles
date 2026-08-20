#!/usr/bin/env python3
"""Scaffold a new project: matching folders in Finder and Obsidian (Google
Drive), a README in the Obsidian folder, and a symlink to it in Finder."""

import os
import sys
from pathlib import Path

FINDER_LOCATION = Path.home() / "Documents" / "01 - Projects"
OBSIDIAN_LOCATION = (
    Path.home() / "My Drive (yimingpengjojo@gmail.com)" / "My_Notes" / "020 - Projects"
)


def create_folders(project_name: str) -> None:
    for location in (FINDER_LOCATION, OBSIDIAN_LOCATION):
        if not location.exists():
            os.makedirs(location)
            print(f"Created directory: {location}")

    project_name = project_name.replace("/", "_").replace("`", " ")

    finder_folder = FINDER_LOCATION / project_name
    obsidian_folder = OBSIDIAN_LOCATION / project_name
    for folder in (finder_folder, obsidian_folder):
        if not folder.exists():
            os.makedirs(folder)
        else:
            print(f"The folder {folder} exists, skipping...")

    md_file_path = obsidian_folder / f"P - README - {project_name}.md"
    if not md_file_path.exists():
        md_file_path.write_text(f"# {project_name}\n\nThis is the README for the project: {project_name}.\n")
        print(f"Created markdown file: {md_file_path}")
    else:
        print(f"The file {md_file_path} exists, skipping...")

    link_path = finder_folder / md_file_path.name
    if not link_path.exists():
        os.symlink(md_file_path.resolve(), link_path)
        print(f"Created symbolic link: {link_path} -> {md_file_path}")
    else:
        print(f"The file {link_path} exists, skipping...")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(f"usage: {Path(sys.argv[0]).name} <project_name>")
    create_folders(sys.argv[1])

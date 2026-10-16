#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This script reads a list of DOIs from a text file and retrieves the metadata
from the CrossRef API. The metadata is then saved as a JSON file.

The input file should have one DOI per line, with the format:
DOI: 10.1234/abcd
"""

import sys
import json
import os
import re
from bs4 import BeautifulSoup
import crossref_commons.retrieval as ccr


class RefEntry(object):
    """
    This class beautifies the content retrieved by the CrossRef API.
    """
    def __init__(self, doi):
        self.doi = doi
        self.content = ccr.get_publication_as_json(self.doi)
        
        # Safe extraction for title
        titles = self.content.get('title', [''])
        self.title = self.clean_html(titles[0]) if titles else ''
        
        self.authors = self.get_authors()
        
        # Safe extraction for journal or publisher
        short_container = self.content.get('short-container-title', [])
        if short_container:
            self.journal = self.clean_html(short_container[0])
        else:
            self.journal = self.content.get('publisher', '')
            
        # Safe extraction for year
        try:
            self.year = self.content['created']['date-parts'][0][0]
        except (KeyError, IndexError):
            self.year = None

        self.abstract = self.clean_html(self.get_abstract())
        self.attributes = self.get_attributes()

    def get_authors(self):
        authors = []
        # Uses .get() to prevent KeyError if 'author' is missing
        for j in self.content.get('author', []):
            family = j.get('family', '')
            given = j.get('given', '')
            author_string = f"{family} {given}".strip()
            if author_string:
                authors.append(author_string)
        return authors
    
    def get_abstract(self):
        return self.content.get('abstract', '')

    def clean_html(self, html_string):
        if not html_string:
            return ''
        soup = BeautifulSoup(html_string, 'html.parser')
        text = soup.get_text()
        clean_text = re.sub(r'\s+', ' ', text).strip()
        clean_text = re.sub(r'^abstract', '', clean_text, flags=re.IGNORECASE)
        return clean_text

    def get_attributes(self):
        return {
            'doi': self.doi,
            'title': self.title,
            'authors': self.authors,
            'journal': self.journal,
            'year': self.year,
            'abstract': self.abstract
        }


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python parse_doi.py <doi_list.txt> <DOI_list.json>")
        sys.exit(1)

    doi_file_path = sys.argv[1]
    json_file_path = sys.argv[2]

    entries = []

    # Load existing JSON if file exists and is not empty
    if os.path.exists(json_file_path) and os.path.getsize(json_file_path) > 0:
        with open(json_file_path, 'r', encoding='utf-8') as jf:
            try:
                entries = json.load(jf)
            except json.JSONDecodeError:
                entries = []

    # Process DOI list file
    with open(doi_file_path, 'r', encoding='utf-8') as df:
        for line in df:
            line = line.strip()
            if not line or ':' not in line:
                continue

            doi = line.split(':', 1)[1].strip()

            # Skip if DOI is already processed
            if any(entry.get('doi') == doi for entry in entries):
                print("DOI already in the JSON file:", doi)
                continue

            print("Processing DOI:", doi)
            try:
                entry = RefEntry(doi)
                entries.append(entry.attributes)
            except Exception as e:
                print(f"Error processing DOI {doi}: {e}")

    # Sort entries by year from newest to oldest
    entries.sort(key=lambda x: x.get('year') or 0, reverse=True)

    # Write updated entries to JSON file
    with open(json_file_path, 'w', encoding='utf-8') as jf:
        json.dump(entries, jf, indent=4, ensure_ascii=False)

    print("Process completed successfully!")
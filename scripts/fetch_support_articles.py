__copyright__ = "Copyright (c) 2026 Alex Laird"
__license__ = "MIT"

"""
Walk Helium's Freshdesk support portal and write one Markdown file per article,
organized in subdirectories matching the portal's category structure.

Stale files (articles removed from the portal) are deleted automatically.

Usage:
    python scripts/fetch_support_articles.py

Invoked via:
    make fetch-support-articles
"""

import logging
import re
import sys
import time
import unicodedata
from pathlib import Path

import html2text
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

BASE_URL = "https://heliumedu.freshdesk.com"

FOLDERS = [
    (159000997310, "getting-started"),
    (159000946696, "calendar-and-schedule"),
    (159000997315, "classes"),
    (159000946697, "grades-and-progress"),
    (159000997313, "reminders-and-notifications"),
    (159000946699, "sync-and-integration"),
    (159000946722, "import-export-and-backup"),
    (159000997314, "resources"),
    (159000997625, "notebook"),
    (159000946695, "account"),
]

OUTPUT_DIR = Path(__file__).parent.parent / "support"

FILE_HEADER = "<!-- Auto-synced from Freshdesk. Do not edit here — changes will be overwritten. To update this article, edit it at: {url} -->\n\n"

SESSION = requests.Session()
SESSION.headers["User-Agent"] = "Mozilla/5.0 (compatible; heliumedu-docs-sync/1.0)"


def slugify(text):
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    return re.sub(r"-+", "-", text).strip("-")


def fetch_soup(url):
    response = SESSION.get(url, timeout=30)
    response.raise_for_status()
    return BeautifulSoup(response.text, "html.parser")


def html_to_md(element):
    h = html2text.HTML2Text()
    h.body_width = 0
    h.ignore_images = True
    return h.handle(str(element)).strip()


def fetch_folder_article_links(folder_id):
    soup = fetch_soup(f"{BASE_URL}/support/solutions/folders/{folder_id}")
    seen = set()
    links = []
    for a in soup.select("a[href*='/support/solutions/articles/']"):
        href = a["href"]
        match = re.search(r"/support/solutions/articles/(\d+)", href)
        if not match:
            continue
        article_id = match.group(1)
        url = f"{BASE_URL}/support/solutions/articles/{article_id}"
        if url in seen:
            continue
        seen.add(url)
        links.append({"url": url, "hint_title": a.get_text(strip=True)})
    return links


def fetch_article(url):
    soup = fetch_soup(url)

    title_el = (
        soup.select_one("h1.heading")
        or soup.select_one("h1.article-title")
        or soup.select_one("h1")
    )
    title = title_el.get_text(strip=True) if title_el else "Untitled"

    body_el = (
        soup.select_one(".article-body")
        or soup.select_one(".solution-article-summary")
        or soup.select_one("article")
    )
    if not body_el:
        logger.warning(f"No article body found at {url}")
        return title, ""

    return title, html_to_md(body_el)


def sync():
    # Existing files scoped to known folder subdirectories only
    existing_files = set()
    for _, folder_slug in FOLDERS:
        folder_dir = OUTPUT_DIR / folder_slug
        if folder_dir.exists():
            existing_files.update(p.resolve() for p in folder_dir.glob("*.md"))

    current_files = set()
    errors = 0

    for folder_id, folder_slug in FOLDERS:
        logger.info(f"Fetching folder: {folder_slug} ({folder_id})")
        folder_dir = OUTPUT_DIR / folder_slug

        try:
            article_links = fetch_folder_article_links(folder_id)
        except Exception as e:
            logger.error(f"  Failed to fetch folder {folder_id}: {e}")
            errors += 1
            continue

        for link in article_links:
            time.sleep(1)
            try:
                title, body = fetch_article(link["url"])
            except Exception as e:
                logger.warning(f"  Skipping {link['url']}: {e}")
                errors += 1
                continue

            if not body:
                continue

            filepath = folder_dir / f"{slugify(title)}.md"
            filepath.parent.mkdir(parents=True, exist_ok=True)
            filepath.write_text(FILE_HEADER.format(url=link["url"]) + f"# {title}\n\nSource: {link['url']}\n\n{body}\n")
            current_files.add(filepath.resolve())
            logger.info(f"  Written: {filepath.relative_to(OUTPUT_DIR.parent)}")

        time.sleep(1)

    # Delete stale files
    for f in existing_files - current_files:
        logger.info(f"Removing stale: {f.relative_to(OUTPUT_DIR.parent)}")
        f.unlink()

    # Prune empty subdirectories
    for _, folder_slug in FOLDERS:
        folder_dir = OUTPUT_DIR / folder_slug
        if folder_dir.exists() and not any(folder_dir.iterdir()):
            folder_dir.rmdir()

    if errors:
        logger.warning(f"{errors} error(s) encountered during sync.")
        sys.exit(1)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")

    logger.info("Syncing Helium support articles from Freshdesk ...")
    sync()
    logger.info("Done.")

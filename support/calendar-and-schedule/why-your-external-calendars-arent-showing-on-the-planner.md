<!-- Auto-synced from Freshdesk. Do not edit here — changes will be overwritten. To update this article, edit it in FreshDesk. -->

# Why Your External Calendars Aren’t Showing on the Planner

Source: https://heliumedu.freshdesk.com/support/solutions/articles/159000418682

If a Google, Apple, or other external calendar isn't appearing inside Helium, the issue is usually related to the External Calendar settings, an invalid URL, or the feed being automatically disabled after an error.

## 1\. Check Your Filters

The Planner has filter options that control what's displayed. If **Remember filter selections** is enabled (found in [**Settings → Preferences**](https://app.heliumedu.com/settings)), filters from a previous session may still be active.

  * A highlighted filter indicator means filters are currently active
  * Verify that **External Calendars** is selected in the filters

## 2\. Wrong View

The **Todos** view displays only Assignments—External Calendars will not appear there. Switch to **Week** , **Day** , **Month** , or **Agenda** view.

## 3\. The External Calendar Is Not Shown on the Planner

Each external calendar has a **Show on calendar** toggle. If it's turned off, the calendar won't appear in the Planner.

**Important:** If Helium encounters an error while loading an External Calendar (for example, an invalid or unreachable URL), it will automatically disable the calendar.

### How to Check

  1. Open [**Settings → External Calendars**](https://app.heliumedu.com/settings)
  2. Find your calendar in the list
  3. Make sure the **Show on calendar** toggle is turned on

If the toggle keeps turning itself off, the URL may be invalid—see the steps below.

## 4\. The iCal/ICS URL Is Incorrect or Invalid

The URL for an External Calendar must return a valid iCal/ICS feed. HTML links to a webpage or a Google Calendar "share" URL will not work.

Check the following:

  * The link ends with `.ics` (not required, but a common sign of a valid feed)
  * The link was copied from your calendar app's "Subscribe" or "Add by URL" option (see [How to Sync Google, Apple, or Other Calendars in to Helium Using External Calendars](https://heliumedu.freshdesk.com/support/solutions/articles/159000418651))
  * There are no extra spaces before or after the URL

If the URL is invalid, Helium will disable the feed automatically the next time it tries to load it.

## 5\. Your Calendar App's iCal/ICS URL Changed

Some services rotate or invalidate feed URLs after account changes (e.g., changing your password, switching accounts, or adjusting privacy settings). If the feed suddenly stopped working:

  * Re-copy the URL from Google or Apple Calendar (see [How to Sync Google, Apple, or Other Calendars in to Helium Using External Calendars](https://heliumedu.freshdesk.com/support/solutions/articles/159000418651))
  * Update it in [**Settings → External Calendars**](https://app.heliumedu.com/settings)

## 6\. The External Calendar Is Refreshing Slowly

Helium refreshes External Calendars on a periodic basis. If the source calendar updates slowly or the calendar provider caches the feed, changes may take time to appear. This is normal.

---

## Helium Classic

The same troubleshooting steps apply in Helium Classic. The key navigation differences are:

  * Filter settings are at [**Account → Settings → Preferences**](https://www.heliumedu.com/settings/#tab-preferences)
  * External Calendars are also managed within [**Account → Settings → Preferences**](https://www.heliumedu.com/settings/#tab-preferences), under the External Calendars section
  * The toggle to show/hide an external calendar is the **Enabled** checkbox (rather than the "Show on calendar" toggle in the new Helium)

_Helium Classic will remain available through at least Summer 2026._

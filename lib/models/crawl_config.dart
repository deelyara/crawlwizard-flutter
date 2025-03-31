import 'package:flutter/material.dart';

enum CrawlType {
  discovery,
  contentExtraction,
  newContentDetection,
  tlsContentExtraction,
}

enum CrawlScope { entireSite, currentPages, specificPages, sitemapPages }

enum SnapshotOption { useExisting, compareContent, rebuildAll, createNew }

enum RecurrenceFrequency { none, daily, weekly, monthly, custom }

class CrawlConfig {
  // Type step
  CrawlType? crawlType;
  bool prerenderPages = false;
  bool useCrest = false;

  // Scope step
  CrawlScope? crawlScope;
  int pageLimit = 100;
  int? maxDepth; // Optional max crawl depth
  List<String> specificUrls = [];
  bool includeNewUrls = false;

  // Restrictions step
  List<String> includePrefixes = [];
  List<String> excludePrefixes = [];
  List<String> regexRestrictions = []; // Added for regex restrictions
  bool makePermanent = false;

  // Snapshot step
  SnapshotOption snapshotOption = SnapshotOption.useExisting;
  String selectedSnapshot = '';
  bool storeNewPages = true;
  bool buildLocalCache = false;

  // Fine-tune step
  bool collectHtmlPages = true;
  bool collectJsCssResources = false;
  bool collectImages = false;
  bool collectBinaryResources = false;
  bool collectErrorPages = false;
  bool collectExternalDomains = false;
  bool collectRedirectionPages = false;
  bool collectShortLinks = false;
  bool skipContentTypeCheck = false;
  bool doNotReloadExistingResources = false;
  bool useEtags = false;
  bool crawlNewUrlsNotInList = false;
  int simultaneousRequests = 5;
  String sessionCookie = '';

  // Recurrence step
  RecurrenceFrequency recurrenceFrequency = RecurrenceFrequency.none;
  TimeOfDay recurrenceTime = const TimeOfDay(hour: 2, minute: 0);
  int recurrenceDayOfWeek = 1; // Monday
  int recurrenceDayOfMonth = 1;
  int recurrenceCustomDays = 7; // Default to weekly for custom days
  bool useRotatingSnapshots = false;
  List<String> selectedRotatingSnapshots = [];
  DateTime? firstScheduledCrawlDate;
  
  // User note for the crawl (optional)
  String? userNote;

  // Helper method to get estimated cost
  double getEstimatedCost() {
    double baseCost = 0;

    // Simple estimation logic
    switch (crawlType) {
      case CrawlType.discovery:
        baseCost = 1.0; // €1 per 1000 pages
        break;
      case CrawlType.contentExtraction:
      case CrawlType.tlsContentExtraction:
        baseCost = 2.0; // €2 per 1000 pages
        break;
      case CrawlType.newContentDetection:
        baseCost = 1.5; // €1.5 per 1000 pages
        break;
      case null:
        return 0.0; // No crawl type selected yet
    }
    
    // Adjust based on resource collection
    if (collectJsCssResources) baseCost += 0.5;
    if (collectImages) baseCost += 1.0;

    // Calculate total
    double totalCost = (pageLimit / 1000) * baseCost;
    return totalCost;
  }
}

import 'package:flutter/material.dart';

enum CrawlType {
  discovery,
  contentExtraction,
  newContentDetection,
  tlsContentExtraction,
}

enum CrawlScope {
  entireSite,
  currentPages,
  specificPages,
  sitemapPages,
  targetLanguageSpecific
}

enum SnapshotOption { useExisting, compareContent, rebuildAll, createNew }

enum RecurrenceFrequency { none, daily, weekly, monthly, custom }

class CrawlConfig {
  // Type step
  CrawlType? crawlType;
  bool prerenderPages = false;
  bool useCrest = false;
  bool generateWorkPackages = false;
  int entriesPerPackage = 100; // Default number of entries per package

  // Scope step
  CrawlScope? crawlScope;
  int pageLimit = 100;
  int? maxDepth; // Optional max crawl depth
  List<String> specificUrls = [];
  List<String> specificPages = [];
  List<String> currentPages = [];
  bool addUnvisitedUrls = false;
  bool collectErrorPages = false;
  bool collectRedirectionPages = false;
  bool autoMarkTranslatable = false;
  bool includeNewUrls = false;
  List<String> targetLanguages = [];
  bool crawlWithoutTargetLanguage = false;

  // Restrictions step
  List<String> includePrefixes = [];
  List<String> excludePrefixes = [];
  List<String> regexRestrictions = [];
  bool makePermanent = false;

  // Snapshot step
  SnapshotOption? snapshotOption;
  String selectedSnapshot = '';
  bool storeNewPages = false;
  bool buildLocalCache = false;

  // Fine-tune step
  bool collectHtmlPages = false;
  bool collectJsCssResources = false;
  bool collectImages = false;
  bool collectBinaryResources = false;
  bool collectExternalDomains = false;
  bool collectShortLinks = false;
  bool skipContentTypeCheck = false;
  bool doNotReloadExistingResources = false;
  bool useEtags = false;
  bool crawlNewUrlsNotInList = false;
  int simultaneousRequests = 8;
  String sessionCookie = '';
  bool markVisitedResourcesAsTranslatable = false;

  // Recurrence step
  RecurrenceFrequency recurrenceFrequency = RecurrenceFrequency.none;
  TimeOfDay recurrenceTime = const TimeOfDay(hour: 2, minute: 0);
  int recurrenceDayOfWeek = 1; // Monday
  int recurrenceDayOfMonth = 1;
  int recurrenceCustomDays = 7;
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

  // Check if recurrence is allowed for the current crawl type
  bool isRecurrenceAllowed() {
    if (crawlType == null) return false;
    
    // TLS Content Extraction and Work Packages don't support recurrence
    if (crawlType == CrawlType.tlsContentExtraction) return false;
    if (generateWorkPackages) return false;
    
    return true;
  }

  // Reset recurrence settings to default values
  void resetRecurrenceSettings() {
    recurrenceFrequency = RecurrenceFrequency.none;
    recurrenceTime = const TimeOfDay(hour: 2, minute: 0);
    recurrenceDayOfWeek = 1;
    recurrenceDayOfMonth = 1;
    recurrenceCustomDays = 7;
    useRotatingSnapshots = false;
    selectedRotatingSnapshots = [];
    firstScheduledCrawlDate = null;
  }
}

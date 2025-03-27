import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easyling_crawl_wizard/models/crawl_config.dart';
import 'package:easyling_crawl_wizard/screens/scope_screen.dart';

void main() {
  group('ScopeScreen Widget Tests', () {
    late CrawlConfig config;
    late VoidCallback mockConfigUpdate;

    setUp(() {
      config = CrawlConfig();
      mockConfigUpdate = () {};
    });

    testWidgets('Should display page limit and max depth fields for entire site option', 
      (WidgetTester tester) async {
      // Arrange
      config.crawlScope = CrawlScope.entireSite;
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScopeScreen(
            config: config,
            onConfigUpdate: mockConfigUpdate,
          ),
        ),
      ));
      
      // Assert
      expect(find.text('Page limit'), findsOneWidget);
      expect(find.text('Max crawl depth limit (optional)'), findsOneWidget);
    });

    testWidgets('Should validate page limit input', (WidgetTester tester) async {
      // Arrange
      config.crawlScope = CrawlScope.entireSite;
      config.pageLimit = 100;
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScopeScreen(
            config: config,
            onConfigUpdate: mockConfigUpdate,
          ),
        ),
      ));
      
      // Enter invalid value (negative)
      await tester.enterText(find.widgetWithText(TextField, '100'), '-50');
      await tester.pump();
      
      // Assert - should revert to previous valid value
      expect(find.widgetWithText(TextField, '100'), findsOneWidget);
      
      // Enter valid value
      await tester.enterText(find.widgetWithText(TextField, '100'), '500');
      await tester.pump();
      
      // Assert - should accept valid value
      expect(find.widgetWithText(TextField, '500'), findsOneWidget);
    });

    testWidgets('Should validate max depth input as optional', (WidgetTester tester) async {
      // Arrange
      config.crawlScope = CrawlScope.entireSite;
      config.maxDepth = null;
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScopeScreen(
            config: config,
            onConfigUpdate: mockConfigUpdate,
          ),
        ),
      ));
      
      // Find the max depth field
      final maxDepthField = find.widgetWithText(TextField, 'Enter crawl depth limit');
      
      // Assert field exists and is empty
      expect(maxDepthField, findsOneWidget);
      
      // Enter valid value
      await tester.enterText(maxDepthField, '3');
      await tester.pump();
      
      // Assert - should accept valid value
      expect(find.widgetWithText(TextField, '3'), findsOneWidget);
      
      // Clear the field
      await tester.enterText(maxDepthField, '');
      await tester.pump();
      
      // Assert - should accept empty value (optional)
      expect(find.widgetWithText(TextField, ''), findsOneWidget);
    });

    testWidgets('Should display tooltips when hovered', (WidgetTester tester) async {
      // Arrange
      config.crawlScope = CrawlScope.entireSite;
      
      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScopeScreen(
            config: config,
            onConfigUpdate: mockConfigUpdate,
          ),
        ),
      ));
      
      // Find info icons
      final pageLimitTooltipIcon = find.byIcon(Icons.info_outline).first;
      final maxDepthTooltipIcon = find.byIcon(Icons.info_outline).last;
      
      // Assert tooltip icons exist
      expect(pageLimitTooltipIcon, findsOneWidget);
      expect(maxDepthTooltipIcon, findsOneWidget);
    });
  });
} 
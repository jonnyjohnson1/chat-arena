import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/analytics_drawer/mermaid_widget.dart';

class GraphAnalyticsDrawer extends StatefulWidget {
  final Function? onTap;

  const GraphAnalyticsDrawer({this.onTap, Key? key}) : super(key: key);

  @override
  State<GraphAnalyticsDrawer> createState() => _GraphAnalyticsDrawerState();
}

class _GraphAnalyticsDrawerState extends State<GraphAnalyticsDrawer> {
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<DisplayConfigData> displayConfigData;

  @override
  void initState() {
    super.initState();
    currentSelectedConversation = Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData = Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);

    debugPrint('\t[ GraphAnalyticsDrawer :: initState ]');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Conversation?>(
      valueListenable: currentSelectedConversation,
      builder: (context, conversation, _) {
        if (conversation == null) {
          return Center(child: Text('No conversation selected'));
        }

        if (conversation.gameType != GameType.debate) {
          return Center(child: Text('Graph analytics are only available for debate conversations'));
        }

        return Column(
          children: [
            _buildTitleBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Debate Structure', style: Theme.of(context).textTheme.titleSmall),
                    ),
                    _buildMermaidChart(conversation),
                    _buildClusterAnalysis(conversation),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Graph Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  // TODO: Implement settings functionality
                },
              ),
              IconButton(
                icon: Icon(Icons.bar_chart),
                onPressed: () {
                  // TODO: Implement chart view toggle
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMermaidChart(Conversation conversation) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Debate Flow', style: Theme.of(context).textTheme.displayMedium),
            SizedBox(height: 16),
            Container(
              height: 300, // Adjust as needed
              child: MermaidWidget(
                mermaidText: conversation.debateData.mermaidChartData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterAnalysis(Conversation conversation) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cluster Analysis', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16),
            _buildClusterList(conversation.debateData.addressedClusters, 'Addressed Clusters'),
            SizedBox(height: 16),
            _buildClusterList(conversation.debateData.unaddressedClusters, 'Unaddressed Clusters'),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterList(Map<String, List<List<dynamic>>> clusters, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 8),
        ...clusters.entries.map((entry) =>
            ListTile(
              title: Text('User: ${entry.key}'),
              subtitle: Text('Clusters: ${entry.value.length}'),
              onTap: () {
                // TODO: Implement cluster detail view
                debugPrint('\t[ Cluster tapped: ${entry.key} ]');
              },
            )
        ),
      ],
    );
  }
}
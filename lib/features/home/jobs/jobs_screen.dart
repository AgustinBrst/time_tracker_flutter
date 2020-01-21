import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../entities/job.dart';
import '../../../services/database_service.dart';
import '../../../widgets/dismissible_list_tile.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/generic_list_view.dart';
import 'edit_job_screen.dart';
import 'job_entries_screen.dart';

class JobsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);

    final appBarTitle = 'Jobs';
    final newJobButton = IconButton(
      icon: Icon(Icons.add, color: Colors.white),
      onPressed: () => _createNewJob(context, databaseService),
    );

    final emptyListTitle = 'No jobs yet';
    final emptyListSubtitle = 'You can create a new one \ntapping the + button';
    final emptyListBody = EmptyState(title: emptyListTitle, subtitle: emptyListSubtitle);

    final loadingListBody = Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: Platform.isIOS,
        elevation: 0,
        actions: [newJobButton],
      ),
      body: StreamBuilder<List<Job>>(
        stream: databaseService.getJobsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return loadingListBody;

          final jobs = snapshot.data;
          if (jobs.isEmpty) return emptyListBody;

          return GenericListView<Job>(
            items: jobs,
            itemBuilder: (context, job) {
              return DismissibleListTile(
                title: job.name,
                key: Key(job.id),
                onDismissed: () => _deleteJob(databaseService, job),
                onTap: () => _goToJobEntries(context, job),
              );
            },
          );
        },
      ),
    );
  }

  void _createNewJob(BuildContext context, databaseService) async {
    await EditJobScreen.show(context, databaseService);
  }

  void _goToJobEntries(BuildContext context, Job job) async {
    await JobEntriesScreen.show(context, job);
  }

  void _deleteJob(DatabaseService databaseService, Job job) {
    databaseService.deleteJob(id: job.id);
  }
}

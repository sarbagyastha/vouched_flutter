import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vouched_flutter/vouched_flutter.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({
    Key? key,
    required this.response,
    required this.image,
  }) : super(key: key);

  final JobResponse response;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final result = response.result;
    final insights = Vouched.extractInsights(response);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
      ),
      body: Scrollbar(
        isAlwaysShown: true,
        child: ListView(
          children: [
            if (image != null)
              AspectRatio(
                aspectRatio: 1,
                child: Image.memory(
                  base64Decode(image!),
                  fit: BoxFit.fitWidth,
                ),
              ),
            for (final insight in insights)
              ListTile(
                title: Text(insight.toString()),
                subtitle: const Text('Insight'),
                tileColor: Theme.of(context).dividerColor,
              ),
            for (final error in response.errors)
              ListTile(
                title: Text(error.message),
                subtitle: Text(error.type),
                tileColor: Theme.of(context).errorColor.withAlpha(50),
              ),
            _DetailTile(
              label: 'First Name',
              value: result?.firstName,
            ),
            _DetailTile(
              label: 'Middle Name',
              value: result?.middleName,
            ),
            _DetailTile(
              label: 'Last Name',
              value: result?.lastName,
            ),
            _DetailTile(
              label: 'Date of Birth',
              value: result?.birthDate,
            ),
            _DetailTile(
              label: 'ID Issue Date',
              value: result?.issueDate,
            ),
            _DetailTile(
              label: 'ID Expiry Date',
              value: result?.expireDate,
            ),
            _DetailTile(
              label: 'ID Type',
              value: result?.type,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final _value = value == null || value!.isEmpty ? 'N/A' : value!;

    return ListTile(
      title: Text(_value),
      subtitle: Text(label),
    );
  }
}

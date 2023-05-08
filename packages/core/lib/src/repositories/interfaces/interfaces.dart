import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

final class RepositoryDataSources<TRemote, TLocal> {
  const RepositoryDataSources({
    required this.local,
    required this.remote,
  });
  RepositoryDataSources.of(final BuildContext context)
      : remote = context.read(),
        local = context.read();
  final TRemote remote;
  final TLocal local;
}

abstract base class Repository<TRemoteSource, TLocalSource> {
  Repository({required this.sources});
  final RepositoryDataSources<TRemoteSource, TLocalSource> sources;
}

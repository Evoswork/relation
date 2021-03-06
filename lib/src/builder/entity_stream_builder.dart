// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';
import 'package:relation/src/relation/state/entity_state.dart';

import '../relation/state/entity_state.dart';

typedef DataWidgetBuilder<T> = Widget Function(BuildContext, T data);
typedef ErrorWidgetBuilder = Widget Function(BuildContext, Exception error);

/// Reactive widget for [EntityStreamedState]
///
/// [streamedState] - external stream that controls the state of the widget
/// widget has three states:
///   [child] - content;
///   [loadingChild] - loading;
///   [errorChild] - error.
///
/// ### example
/// ```dart
/// EntityStateBuilder<Data>(
///      streamedState: wm.dataState,
///      child: (data) => DataWidget(data),
///      loadingChild: LoadingWidget(),
///      errorChild: ErrorPlaceholder(),
///    );
///  ```
class EntityStateBuilder<T> extends StatelessWidget {
  /// StreamedState of entity
  final EntityStreamedState<T> streamedState;

  /// Child of builder
  final DataWidgetBuilder<T> child;

  /// Loading child of builder
  final DataWidgetBuilder<T> loadingBuilder;

  /// Error child of builder
  final DataWidgetBuilder<T> errorBuilder;

  /// Loading child widget
  final Widget loadingChild;

  /// Error child widget
  final Widget errorChild;

  const EntityStateBuilder({
    Key key,
    @required this.streamedState,
    @required this.child,
    this.loadingBuilder,
    this.errorBuilder,
    Widget loadingChild,
    Widget errorChild,
  })  : loadingChild = loadingChild ?? const SizedBox(),
        errorChild = errorChild ?? const SizedBox(),
        assert(streamedState != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EntityState<T>>(
      stream: streamedState.stream,
      initialData: streamedState.value,
      builder: (context, snapshot) {
        final streamData = snapshot.data;
        switch (streamData.stateWidget) {
          case StateWidget.content:
            return child(context, streamData.data);
          case StateWidget.loading:
            return streamData?.data != null
                   ? loadingBuilder(context, streamData.data)
                   : loadingChild;
          case StateWidget.error:
          default:
            return streamData.data != null
                   ? errorBuilder(context, streamData.data)
                   : errorChild;
        }
      },
    );
  }
}

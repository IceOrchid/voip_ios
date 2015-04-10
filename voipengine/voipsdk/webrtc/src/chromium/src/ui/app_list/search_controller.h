// Copyright 2013 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef UI_APP_LIST_SEARCH_CONTROLLER_H_
#define UI_APP_LIST_SEARCH_CONTROLLER_H_

#include "base/basictypes.h"
#include "base/memory/scoped_ptr.h"
#include "base/memory/scoped_vector.h"
#include "base/timer/timer.h"
#include "ui/app_list/app_list_export.h"
#include "ui/app_list/app_list_model.h"
#include "ui/app_list/search/mixer.h"
#include "ui/app_list/speech_ui_model_observer.h"

namespace app_list {

class History;
class SearchBoxModel;
class SearchProvider;
class SearchResult;

// Controller that collects query from given SearchBoxModel, dispatches it
// to all search providers, then invokes the mixer to mix and to publish the
// results to the given SearchResults UI model.
class APP_LIST_EXPORT SearchController {
 public:
  SearchController(SearchBoxModel* search_box,
                   AppListModel::SearchResults* results,
                   History* history);
  virtual ~SearchController();

  void Start();
  void Stop();

  void OpenResult(SearchResult* result, int event_flags);
  void InvokeResultAction(SearchResult* result,
                          int action_index,
                          int event_flags);

  // Takes ownership of |provider| and associates it with given mixer group.
  void AddProvider(Mixer::GroupId group,
                   scoped_ptr<SearchProvider> provider);

 private:
  typedef ScopedVector<SearchProvider> Providers;

  // Invoked when the search results are changed.
  void OnResultsChanged();

  SearchBoxModel* search_box_;

  bool dispatching_query_;
  Providers providers_;
  scoped_ptr<Mixer> mixer_;
  History* history_;  // KeyedService, not owned.

  base::OneShotTimer<SearchController> stop_timer_;

  DISALLOW_COPY_AND_ASSIGN(SearchController);
};

}  // namespace app_list

#endif  // UI_APP_LIST_SEARCH_CONTROLLER_H_
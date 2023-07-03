import 'package:flutter/material.dart';

import 'package:flutter_scrollbar_modified/flutter_scrollbar_modified.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import 'package:namida/controller/indexer_controller.dart';
import 'package:namida/controller/scroll_search_controller.dart';
import 'package:namida/controller/settings_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/enums.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/namida_converter_ext.dart';
import 'package:namida/core/translations/strings.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';
import 'package:namida/ui/widgets/expandable_box.dart';
import 'package:namida/ui/widgets/library/album_card.dart';
import 'package:namida/ui/widgets/library/album_tile.dart';
import 'package:namida/ui/widgets/sort_by_button.dart';

class AlbumsPage extends StatelessWidget {
  final List<String>? albums;
  final int countPerRow;

  const AlbumsPage({super.key, this.albums, required this.countPerRow});

  ScrollController get _scrollController => LibraryTab.albums.scrollController;

  @override
  Widget build(BuildContext context) {
    final finalAlbums = albums ?? Indexer.inst.albumSearchList;
    return BackgroundWrapper(
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: AnimationLimiter(
          child: Column(
            children: [
              Obx(
                () => ExpandableBox(
                  gridWidget: ChangeGridCountWidget(
                    currentCount: countPerRow,
                    forStaggered: SettingsController.inst.useAlbumStaggeredGridView.value,
                    onTap: () {
                      final newCount = ScrollSearchController.inst.animateChangingGridSize(LibraryTab.albums, countPerRow);
                      SettingsController.inst.save(albumGridCount: newCount);
                    },
                  ),
                  isBarVisible: LibraryTab.albums.isBarVisible,
                  showSearchBox: LibraryTab.albums.isSearchBoxVisible,
                  leftText: finalAlbums.length.displayAlbumKeyword,
                  onFilterIconTap: () => ScrollSearchController.inst.switchSearchBoxVisibilty(LibraryTab.albums),
                  onCloseButtonPressed: () => ScrollSearchController.inst.clearSearchTextField(LibraryTab.albums),
                  sortByMenuWidget: SortByMenu(
                    title: SettingsController.inst.albumSort.value.toText(),
                    popupMenuChild: const SortByMenuAlbums(),
                    isCurrentlyReversed: SettingsController.inst.albumSortReversed.value,
                    onReverseIconTap: () => Indexer.inst.sortAlbums(reverse: !SettingsController.inst.albumSortReversed.value),
                  ),
                  textField: CustomTextFiled(
                    textFieldController: LibraryTab.albums.textSearchController,
                    textFieldHintText: Language.inst.FILTER_ALBUMS,
                    onTextFieldValueChanged: (value) => Indexer.inst.searchAlbums(value),
                  ),
                ),
              ),
              Obx(
                () {
                  return countPerRow == 1
                      ? Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: finalAlbums.length,
                            itemExtent: SettingsController.inst.albumListTileHeight.value + 4.0 * 5,
                            padding: const EdgeInsets.only(bottom: kBottomPadding),
                            itemBuilder: (BuildContext context, int i) {
                              final albumName = finalAlbums[i];
                              return AnimatingTile(
                                position: i,
                                shouldAnimate: LibraryTab.albums.shouldAnimateTiles,
                                child: AlbumTile(
                                  name: albumName,
                                  album: albumName.getAlbumTracks(),
                                ),
                              );
                            },
                          ),
                        )
                      : SettingsController.inst.useAlbumStaggeredGridView.value
                          ? Expanded(
                              child: MasonryGridView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(bottom: kBottomPadding),
                                itemCount: finalAlbums.length,
                                mainAxisSpacing: 8.0,
                                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: countPerRow),
                                itemBuilder: (context, i) {
                                  final albumName = finalAlbums[i];
                                  return AnimatingGrid(
                                    columnCount: finalAlbums.length,
                                    position: i,
                                    shouldAnimate: LibraryTab.albums.shouldAnimateTiles,
                                    child: AlbumCard(
                                      name: albumName,
                                      album: albumName.getAlbumTracks(),
                                      staggered: true,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: countPerRow, childAspectRatio: 0.75, mainAxisSpacing: 8.0),
                                controller: _scrollController,
                                itemCount: finalAlbums.length,
                                padding: const EdgeInsets.only(bottom: kBottomPadding),
                                itemBuilder: (BuildContext context, int i) {
                                  final albumName = finalAlbums[i];
                                  return AnimatingGrid(
                                    columnCount: finalAlbums.length,
                                    position: i,
                                    shouldAnimate: LibraryTab.albums.shouldAnimateTiles,
                                    child: AlbumCard(
                                      name: albumName,
                                      album: albumName.getAlbumTracks(),
                                      gridCountOverride: countPerRow,
                                      staggered: false,
                                    ),
                                  );
                                },
                              ),
                            );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

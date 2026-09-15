import 'package:milsat_dropdown_textfield/tooltip_widget.dart';
import 'package:flutter/material.dart';

import 'dropdown_textfield.dart';

class MultiSelection extends StatefulWidget {
  const MultiSelection(
      {Key? key,
      required this.onChanged,
      required this.dropDownList,
      required this.list,
      required this.height,
      this.buttonColor,
      this.buttonText,
      this.buttonTextStyle,
      required this.listTileHeight,
      required this.listPadding,
      this.listTextStyle,
      this.checkBoxProperty,
      this.enableSearch = false,
      this.searchHeight = 60,
      this.searchTextStyle,
      this.searchFocusNode,
      this.searchKeyboardType,
      this.searchShowCursor,
      this.searchDecoration,
      this.clearIconProperty,
      this.onSearchTap,
      this.onSearchSubmit})
      : super(key: key);
  final List<DropDownValueModel> dropDownList;
  final ValueSetter onChanged;
  final List<bool> list;
  final double height;
  final Color? buttonColor;
  final String? buttonText;
  final TextStyle? buttonTextStyle;
  final double listTileHeight;
  final TextStyle? listTextStyle;
  final ListPadding listPadding;
  final CheckBoxProperty? checkBoxProperty;

  ///by setting enableSearch=true enable search option in this multi-select
  ///dropdown -- selections already made are preserved across searches since
  ///checked state is tracked against the full [dropDownList], not the
  ///currently-filtered view.
  final bool enableSearch;
  final double searchHeight;
  final TextStyle? searchTextStyle;
  final FocusNode? searchFocusNode;
  final TextInputType? searchKeyboardType;
  final bool? searchShowCursor;
  final InputDecoration? searchDecoration;
  final IconProperty? clearIconProperty;
  final Function? onSearchTap;
  final Function? onSearchSubmit;

  @override
  _MultiSelectionState createState() => _MultiSelectionState();
}

class _MultiSelectionState extends State<MultiSelection> {
  List<bool> multiSelectionValue = [];

  // Indices into widget.dropDownList/multiSelectionValue that are currently
  // visible -- kept separate from the selection state itself so filtering
  // never disturbs which items are checked, even across repeated searches.
  late List<int> _visibleIndices;
  late TextEditingController _searchCnt;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    multiSelectionValue = List.from(widget.list);
    _visibleIndices = List.generate(widget.dropDownList.length, (i) => i);
    _searchCnt = TextEditingController();
    _searchFocusNode = widget.searchFocusNode ?? FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _searchCnt.dispose();
    if (widget.searchFocusNode == null) _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _visibleIndices = List.generate(widget.dropDownList.length, (i) => i);
      } else {
        final query = value.toLowerCase();
        _visibleIndices = [
          for (var i = 0; i < widget.dropDownList.length; i++)
            if (widget.dropDownList[i].name.toLowerCase().contains(query)) i,
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.enableSearch)
          SizedBox(
            height: widget.searchHeight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                style: widget.searchTextStyle,
                focusNode: _searchFocusNode,
                showCursor: widget.searchShowCursor,
                keyboardType: widget.searchKeyboardType,
                controller: _searchCnt,
                onTap: () {
                  if (widget.onSearchTap != null) {
                    widget.onSearchTap!();
                  }
                },
                decoration: (widget.searchDecoration ?? const InputDecoration())
                    .copyWith(
                  hintText:
                      widget.searchDecoration?.hintText ?? 'Search Here...',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _searchCnt.clear();
                      _onSearchChanged("");
                    },
                    child: _searchFocusNode.hasFocus
                        ? InkWell(
                            child: Icon(
                              widget.clearIconProperty?.icon ?? Icons.close,
                              size: widget.clearIconProperty?.size,
                              color: widget.clearIconProperty?.color,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                onChanged: _onSearchChanged,
                onSubmitted: (val) {
                  if (widget.onSearchSubmit != null) {
                    widget.onSearchSubmit!();
                  }
                },
              ),
            ),
          ),
        SizedBox(
          height: widget.height,
          child: Scrollbar(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _visibleIndices.length,
                itemBuilder: (BuildContext context, int position) {
                  final index = _visibleIndices[position];
                  return SizedBox(
                    height: widget.listTileHeight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: widget.listPadding.bottom,
                          top: widget.listPadding.top),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        widget.dropDownList[index]
                                                .prefixWidget ??
                                            const SizedBox.shrink(),
                                        Text(
                                          widget.dropDownList[index].name,
                                          style: widget.listTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (widget.dropDownList[index].toolTipMsg !=
                                      null)
                                    ToolTipWidget(
                                        msg: widget
                                            .dropDownList[index].toolTipMsg!)
                                ],
                              ),
                            ),
                          ),
                          Checkbox(
                            value: multiSelectionValue[index],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  multiSelectionValue[index] = value;
                                });
                              }
                            },
                            tristate:
                                widget.checkBoxProperty?.tristate ?? false,
                            mouseCursor: widget.checkBoxProperty?.mouseCursor,
                            activeColor: widget.checkBoxProperty?.activeColor,
                            fillColor: widget.checkBoxProperty?.fillColor,
                            checkColor: widget.checkBoxProperty?.checkColor,
                            focusColor: widget.checkBoxProperty?.focusColor,
                            hoverColor: widget.checkBoxProperty?.hoverColor,
                            overlayColor: widget.checkBoxProperty?.overlayColor,
                            splashRadius: widget.checkBoxProperty?.splashRadius,
                            materialTapTargetSize:
                                widget.checkBoxProperty?.materialTapTargetSize,
                            visualDensity:
                                widget.checkBoxProperty?.visualDensity,
                            focusNode: widget.checkBoxProperty?.focusNode,
                            autofocus:
                                widget.checkBoxProperty?.autofocus ?? false,
                            shape: widget.checkBoxProperty?.shape,
                            side: widget.checkBoxProperty?.side,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
        Row(
          children: [
            const Expanded(
              child: SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 8.0, left: 8.0, top: 15, bottom: 10),
              child: InkWell(
                onTap: () => widget.onChanged(multiSelectionValue),
                child: Container(
                  height: widget.listTileHeight * 0.9,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12),
                  decoration: BoxDecoration(
                      color: widget.buttonColor ?? Colors.green,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: Align(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        widget.buttonText ?? "Ok",
                        style: widget.buttonTextStyle ??
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

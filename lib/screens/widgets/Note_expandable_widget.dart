import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gark_academy/models/test_model.dart';

class NoteExpandableSection extends StatefulWidget {
  final String title;
  final bool isExpanded;
  final bool editable;
  final List<Category> categories;

  const NoteExpandableSection({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.categories,
    this.editable = true,
  });

  @override
  _NoteExpandableSectionState createState() => _NoteExpandableSectionState();
}

class _NoteExpandableSectionState extends State<NoteExpandableSection> {
  bool _isExpanded = false;
  late List<Category> _categories;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _categories = widget.categories;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.012,
        horizontal: MediaQuery.of(context).size.width * 0.052,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width * 0.042,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),
          if (_isExpanded)
            Column(
              children: _categories.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...category.kpis.map((kpi) => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.012),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    kpi.kpiType,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.036,
                                    ),
                                  ),
                                  widget.editable
                                      ? Row(
                                          children: [
                                            _buildRadioButton(kpi, 1),
                                            _buildRadioButton(kpi, 2),
                                            _buildRadioButton(kpi, 3),
                                          ],
                                        )
                                      : kpi.value != null
                                          ? Text(
                                              "Selected: ${kpi.value ?? ""}",
                                              style: GoogleFonts.montserrat(
                                                color: Colors.grey[700],
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.031,
                                              ),
                                            )
                                          : const SizedBox(),
                                ],
                              ),
                              widget.editable
                                  ? _buildCommentField(kpi)
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.012),
                                      child: Text(
                                        kpi.comment ?? 'No comment',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.grey[700],
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.031,
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.025),
                            ],
                          ),
                        )),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(KPI kpi, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        children: [
          Radio<int>(
            value: value,
            groupValue: kpi.value,
            onChanged: widget.editable
                ? (value) {
                    setState(() {
                      kpi.value = value;
                    });
                  }
                : null,
          ),
          Text(
            value.toString(),
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width * 0.031,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentField(KPI kpi) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.012),
      child: TextFormField(
        initialValue: kpi.comment ?? '',
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          labelText: 'Commentaire',
          alignLabelWithHint: true,
        ),
        maxLines: null,
        enabled: widget.editable,
        onChanged: (value) {
          setState(() {
            kpi.comment = value;
          });
        },
      ),
    );
  }
}

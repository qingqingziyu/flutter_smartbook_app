import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

class Books {
  String id;

  bool allowMonthly;

  String author;

  int banned;

  String contentType;

  String cover;

  String lastChapter;

  int latelyFollower;

  String majorCate;

  String minorCate;

  Object retentionRatio;

  String shortIntro;

  String site;

  int sizetype;

  String superscript;

  List<String> tags;

  String title;

  Books(
      this.id,
      this.allowMonthly,
      this.author,
      this.banned,
      this.contentType,
      this.cover,
      this.lastChapter,
      this.latelyFollower,
      this.majorCate,
      this.minorCate,
      this.retentionRatio,
      this.shortIntro,
      this.site,
      this.sizetype,
      this.superscript,
      this.tags,
      this.title);

  Books.fromJson(Map<String, dynamic> json) {
    this.id = json['_id'];
    this.allowMonthly = json['allowMonthly'];
    this.author = json['author'];
    this.banned = json['banned'];
    this.contentType = json['contentType'];
    this.cover = json['cover'];
    this.lastChapter = json['lastChapter'];
    this.latelyFollower = json['latelyFollower'];
    this.majorCate = json['majorCate'];
    this.minorCate = json['minorCate'];
    this.retentionRatio = json['retentionRatio'];
    this.shortIntro = json['shortIntro'];
    this.site = json['site'];
    this.sizetype = json['sizetype'];
    this.superscript = json['superscript'];
    if (json['tags']!=null) {
      tags =new List();
      json['tags'].forEach((e){
        tags.add(e);
      });
    }
    this.title = json['title'];
  }
}

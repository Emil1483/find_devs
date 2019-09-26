import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geohash/geohash.dart';

class GeohashHelper {
  static final int geohashLength = 2;
  final double lat;
  final double lng;

  Offset _pos = Offset(0, 1);
  HashSet<int> _beenBefore = HashSet<int>();
  HashSet<String> _results = HashSet<String>();
  Offset _dir = Offset(-1, 0);

  double _cellWidth;
  double _cellHeight;
  int _totalCells;

  GeohashHelper(this.lat, this.lng) {
    _cellWidth = 45 / pow(2, _sum(geohashLength, true));
    _cellHeight = 45 / pow(2, _sum(geohashLength, false));
    _totalCells = pow(32, geohashLength);
  }

  static String getHash(double lat, double lng) {
    return Geohash.encode(
      lat,
      lng,
      codeLength: geohashLength,
    );
  }

  Offset _rotated(Offset offset) {
    return Offset.fromDirection(offset.direction + pi / 2);
  }

  int _sum(int len, bool startAt2) {
    int sum = 0;
    int add = startAt2 ? 2 : 3;
    for (int i = 0; i < len - 1; i++) {
      sum += add;
      add = add == 2 ? 3 : 2;
    }
    return sum;
  }

  void _rotate() {
    _dir = Offset.fromDirection(_dir.direction + pi / 2);
  }

  double _format(double x) {
    return (x + 180) % 360 - 180;
  }

  Offset _round(Offset offset) {
    return Offset(offset.dx.round().toDouble(), offset.dy.round().toDouble());
  }

  String next() {
    //TODO optimize
    if (_results.length >= _totalCells) return null;

    final rotated = _rotated(_dir);
    final newPos = _round(_pos + rotated);
    if (!_beenBefore.contains(newPos.hashCode)) _rotate();
    _pos += _round(_dir);
    _beenBefore.add(_pos.hashCode);

    Offset place = Offset(
      _format(lat + _pos.dy * _cellHeight),
      _format(lng + _pos.dx * _cellWidth),
    );
    String result = getHash(place.dx, place.dy);
    
    if (_results.contains(result)) return next();
    _results.add(result);

    return result;
  }
}

#ifndef _RECTANGLE_H
#define _RECTANGLE_H

#include "Point.h"

class Rectangle
{
public:
  Rectangle();
  Rectangle(Point bl, Point tr);
  void move(int dx, int dy);
  Point get_bottom_left() const;
  Point get_top_right() const;
  int width() const;
  int height() const;
  int area() const;

private:
  Point bottom_left;
  Point top_right;
};

#endif

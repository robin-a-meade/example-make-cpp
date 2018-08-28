/*
 *          File: Point.h
 * Last Modified: January 31, 2000
 *         Topic: Modules, Separate Compilation, Using Make Files
 * ----------------------------------------------------------------
 */

class Point
{
public:
  Point();
  Point(int xval, int yval);
  void move(int dx, int dy);
  int get_x() const;
  int get_y() const;

private:
  int x;
  int y;
};

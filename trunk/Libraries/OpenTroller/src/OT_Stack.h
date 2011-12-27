/*
    Copyright (C) 2011 Matt Reba (mattreba at oscsys dot com)
    Copyright (C) 2011 Timothy Reaves (treaves at silverfieldstech dot com)

    This file is part of OpenTroller.

    OpenTroller is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenTroller is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenTroller.  If not, see <http://www.gnu.org/licenses/>.


*/
#ifndef OT_STACK_H
#define OT_STACK_H


namespace OpenTroller {

    /**
      * This is the entry point for the OpenTroller framework stack.
      */
    class stack {
      public:
        /**
          * This method needs to be called as early in the application as possible, to initialize
          * the framework for use.  This method will further initialize any hardware defined for
          * use by the framework in OT_HWProfile.h.
          */
        void init();

        /**
          * Insures the framework is updated.  Should be called once per loop.
          */
        void update();

    };

    /**
      * The singleton instance of the framework.
      */
    extern OpenTroller::stack Stack;
}
#endif // OT_STACK_H

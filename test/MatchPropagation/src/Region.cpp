// ========================================================================== //
// This file is part of DO++ MatchPropagation which was presented in:
//
//  Efficient and Scalable 4th-order Match Propagation
//  David Ok, Renaud Marlet, and Jean-Yves Audibert.
//  ACCV 2012, Daejeon, South Korea.
//
// Copyright (c) 2013. David Ok, Imagine (ENPC/CSTB).
// ========================================================================== //

#include "Region.hpp"

using namespace std;

namespace DO {

  vector<Match> Region::matches(const vector<Match>& M) const
  {
    vector<Match> R;
    R.reserve(indices.size());
    for (const_iterator i = begin(); i != end(); ++i)
      R.push_back(M[*i]);
    return R;
  }

  bool Region::find(const Match &m, const vector<Match>& M) const
  {
    size_t index = &m - &M[0];
    return find(index);
  }

  bool Region::insert(const Match& m, const vector<Match>& M)
  {
    size_t index = &m - &M[0];
    if (find(m, M))
      return false;
    insert(index);
    return true;
  }

  void Region::view(const vector<Match>& M,
                    const PairWiseDrawer& drawer, const Rgb8& c) const
  {
    for (const_iterator i = begin(); i != end(); ++i)
      drawer.drawMatch(M[*i], c);
  }

  ostream& operator<<(ostream& os, const Region& R)
  {
    os << "Matches of the region:" << endl;
    for (Region::const_iterator m = R.begin(); m != R.end(); ++m)
      os << *m << " ";
    os << endl;
    return os;
  }

} /* namespace DO */
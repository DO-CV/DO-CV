// ========================================================================== //
// This file is part of Sara, a basic set of libraries in C++ for computer
// vision.
//
// Copyright (C) 2013-2016 David Ok <david.ok8@gmail.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License v. 2.0. If a copy of the MPL was not distributed with this file,
// you can obtain one at http://mozilla.org/MPL/2.0/.
// ========================================================================== //

#define BOOST_TEST_MODULE "Core/Numpy-like Functions"

#include <DO/Sara/Core/Numpy.hpp>

#include <boost/test/unit_test.hpp>


using namespace DO::Sara;


BOOST_AUTO_TEST_CASE(test_arange)
{
   auto samples = arange(0.5, 1.5, 0.1);
   auto true_samples = Eigen::VectorXd(10);
   true_samples << 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4;
   BOOST_CHECK_LE((samples - true_samples).norm(), 1e-9);

   static_assert(std::is_same<decltype(double{} * float{} * int{}),
                              double>::value, "");
}

BOOST_AUTO_TEST_CASE(test_vstack)
{
  auto matrices = std::vector<Eigen::MatrixXi>{
    Eigen::MatrixXi::Ones(1, 3),
    Eigen::MatrixXi::Ones(3, 3) * 2,
    Eigen::MatrixXi::Ones(5, 3) * 3,
  };

  auto vstack_res = vstack(matrices);

  auto true_vstack_res = Eigen::MatrixXi(9, 3);
  true_vstack_res <<                   //
     Eigen::MatrixXi::Ones(1, 3),      //
     Eigen::MatrixXi::Ones(3, 3) * 2,  //
     Eigen::MatrixXi::Ones(5, 3) * 3;

  BOOST_CHECK(vstack_res == true_vstack_res);
}

BOOST_AUTO_TEST_CASE(test_meshgrid)
{
   auto x = Eigen::MatrixXd(3, 1);
   auto y = Eigen::MatrixXd(2, 1);

   x << 0., 0.5, 1.;
   y << 0., 1.;

   Eigen::MatrixXd xv, yv;
   std::tie(xv, yv) = meshgrid(x, y);

   auto true_xv = Eigen::MatrixXd(3, 2);
   auto true_yv = Eigen::MatrixXd(3, 2);
   true_xv << 0. , 0  ,
              0.5, 0.5,
              1. , 1. ;
   true_yv << 0., 1.,
              0., 1.,
              0., 1.;

   BOOST_CHECK_EQUAL(xv.rows(), 3);
   BOOST_CHECK_EQUAL(xv.cols(), 2);
   BOOST_CHECK(xv == true_xv);

   BOOST_CHECK_EQUAL(yv.rows(), 3);
   BOOST_CHECK_EQUAL(yv.cols(), 2);
   BOOST_CHECK(yv == true_yv);
}
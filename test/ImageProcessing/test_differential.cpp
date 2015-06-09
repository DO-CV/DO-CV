// ========================================================================== //
// This file is part of DO-CV, a basic set of libraries in C++ for computer
// vision.
//
// Copyright (C) 2013 David Ok <david.ok8@gmail.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License v. 2.0. If a copy of the MPL was not distributed with this file,
// you can obtain one at http://mozilla.org/MPL/2.0/.
// ========================================================================== //


#include <gtest/gtest.h>

#include <DO/Sara/ImageProcessing/Differential.hpp>

#include "../AssertHelpers.hpp"


using namespace std;
using namespace DO::Sara;


class TestDifferential : public testing::Test
{
protected:
  Image<float> _src_image;
  vector<float> _kernel;

  TestDifferential() : testing::Test()
  {
    _src_image.resize(3, 3);
    _src_image.matrix() <<
      1, 2, 3,
      1, 2, 3,
      1, 2, 3;

    _kernel.resize(3);
    _kernel[0] = -1./2;
    _kernel[1] =  0;
    _kernel[2] =  1./2;
  }
};

TEST_F(TestDifferential, test_gradient)
{
  Image<float>& f = _src_image;
  Vector2i x(1, 1);
  Gradient<float> compute_gradient(f);

  Vector2f gradf_x;
  compute_gradient(gradf_x, x);
  EXPECT_MATRIX_NEAR(Vector2f(1,0), gradf_x, 1e-5);

  Image<Vector2f> gradf;
  compute_gradient(gradf);
  for (int y = 0; y < gradf.height(); ++y)
  {
    for (int x = 0; x < gradf.width(); ++x)
    {
      Vector2f true_gradf;
      true_gradf[0] = x == 1 ? 1 : 0.5f;
      true_gradf[1] = 0;
      Vector2f gradf_xy = gradf(x, y);
      EXPECT_MATRIX_NEAR(true_gradf, gradf_xy, 1e-5);
    }
  }
}

TEST_F(TestDifferential, test_laplacian)
{
  Image<float>& f = _src_image;
  f.matrix() <<
    1, 1, 1,
    1, 1, 1,
    1, 1, 1;
  Vector2i x(1, 1);
  Laplacian<float> compute_laplacian(_src_image);

  float laplacian_x = compute_laplacian(x);
  EXPECT_NEAR(0, laplacian_x, 1e-5);

  Image<float> laplacian;
  MatrixXf true_laplacian(3, 3);
  true_laplacian.setZero();
  compute_laplacian(laplacian);
  EXPECT_MATRIX_NEAR(laplacian.matrix(), true_laplacian, 1e-5);
}

TEST_F(TestDifferential, test_hessian)
{
  Image<float>& f = _src_image;
  f.matrix() <<
    1, 1, 1,
    1, 1, 1,
    1, 1, 1;
  Vector2i x(1, 1);
  Hessian<float> compute_hessian(f);

  Matrix2f H_x;
  Matrix2f true_H_x = Matrix2f::Zero();
  compute_hessian(H_x, x);
  EXPECT_MATRIX_NEAR(true_H_x, H_x, 1e-5);

  Image<Matrix2f> hessian_f;
  compute_hessian(hessian_f);
  for (int y = 0; y < hessian_f.height(); ++y)
  {
    for (int x = 0; x < hessian_f.width(); ++x)
    {
      Matrix2f true_hessian;
      true_hessian.setZero();
      Matrix2f hessian = hessian_f(x, y);
      EXPECT_MATRIX_NEAR(true_hessian, hessian, 1e-5);
    }
  }
}

TEST_F(TestDifferential, test_laplacian_2)
{
  /*
    We test the following function:
    f(x,y) = x^2 + y^2
    So the laplacian is a constant function, i.e.: tr(D^2 f) (x,y) = 4
    for any (x,y).
  */

  Image<float> f(4,4);
  f.matrix() <<
    0,  1,  4,  9,
    1,  2,  5, 10,
    4,  5,  8, 13,
    9, 10, 13, 18;

  Image<float> laplacian_f;
  laplacian_f = laplacian(f);

  Matrix2f actual_central_block = laplacian_f.matrix().block<2, 2>(1, 1);
  Matrix2f expected_central_block = 4 * Matrix2f::Ones();
  EXPECT_MATRIX_EQ(expected_central_block, actual_central_block);
}

TEST_F(TestDifferential, test_hessian_2)
{
  /*
    We test the following function:
    f(x,y) = xy;
    Thus the Hessian function should be equal to:
    Hf(x,y) = [0 1
               1 0]
    at any point (x,y)
  */

  Image<float> f(4, 4);
  f.matrix() <<
    0, 0, 0, 0,
    0, 1, 2, 3,
    0, 2, 4, 6,
    0, 3, 6, 9;

  //Hessian<float> compute_hessian(f);
  Image<Matrix2f> Hf = hessian(f);

  Matrix2f expected_hessian;
  expected_hessian <<
    0, 1,
    1, 0;
  for (int y = 1; y < 3; ++y)
    for (int x = 1; x < 3; ++x)
      ASSERT_MATRIX_EQ(expected_hessian, Hf(x, y));
}



int main(int argc, char** argv)
{
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
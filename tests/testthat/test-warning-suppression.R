# Tests for W-R8: .suppress_worker_build_warnings is targeted, not blanket.

test_that("non-matching warnings propagate through suppressor", {
  result <- NULL
  expect_warning(
    result <- rajiveplus:::.suppress_worker_build_warnings({
      warning("this is an unexpected warning")
      42L
    }),
    regexp = "this is an unexpected warning"
  )
  expect_equal(result, 42L)
})

test_that("'was built under R version' warnings are muffled", {
  result <- withCallingHandlers(
    rajiveplus:::.suppress_worker_build_warnings({
      warning("package 'foo' was built under R version 4.3.1")
      99L
    }),
    warning = function(w) {
      testthat::fail(paste0("Warning should have been muffled: ", conditionMessage(w)))
      invokeRestart("muffleWarning")
    }
  )
  expect_equal(result, 99L)
})

test_that("'loaded from a different R version' warnings are muffled", {
  result <- withCallingHandlers(
    rajiveplus:::.suppress_worker_build_warnings({
      warning("package 'bar' was loaded from a different R version 4.2.0")
      7L
    }),
    warning = function(w) {
      testthat::fail(paste0("Warning should have been muffled: ", conditionMessage(w)))
      invokeRestart("muffleWarning")
    }
  )
  expect_equal(result, 7L)
})

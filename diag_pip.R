library(rajiveplus)

cat("=== local_js_fixture with seed 1 ===\n")
set.seed(1L)
Y <- ajive.data.sim(K=2, rankJ=2, rankA=c(4,3), n=60, pks=c(80,60), dist.type=1)
fit <- withr::with_seed(1L, Rajive(Y$sim_data, initial_signal_ranks=c(4,3),
                                   n_wedin_samples=20, n_rand_dir_samples=20))
cat("joint_rank:", fit$joint_rank, "\n")
cat("ncol(joint_scores):", ncol(fit$joint_scores), "\n")

cat("\n=== jackstraw_rajive (no pip_group) ===\n")
js1 <- tryCatch(
  withr::with_seed(42L, jackstraw_rajive(fit, Y$sim_data, n_null=5, pip=TRUE)),
  error = function(e) { cat("ERROR:", conditionMessage(e), "\n"); NULL }
)
if (!is.null(js1)) cat("OK: attr(joint_rank)=", attr(js1,"joint_rank"), "\n")

cat("\n=== jackstraw_rajive (pip_group='component') ===\n")
js2 <- tryCatch(
  withr::with_seed(42L, jackstraw_rajive(fit, Y$sim_data, n_null=5, pip=TRUE,
                                          pip_group="component")),
  error = function(e) { cat("ERROR:", conditionMessage(e), "\n"); NULL }
)
if (!is.null(js2)) cat("OK: attr(joint_rank)=", attr(js2,"joint_rank"), "\n")

cat("\n=== Done ===\n")

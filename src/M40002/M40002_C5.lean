-- M40002 (Analysis I) Chapter 5. Continuity

import M40002.M40002_C4
import data.polynomial

namespace M40002

-- Definition of limits of functions (f(x) → b as x → a)
def func_converges_to (f : ℝ → ℝ) (a b : ℝ) := ∀ ε > 0, ∃ δ > 0, ∀ x : ℝ, abs (x - a) < δ → abs (f x - b) < ε

-- Definition of continuity at a point
def func_continuous_at (f : ℝ → ℝ) (a : ℝ) := func_converges_to f a (f a)

-- Definition of a continuous function
def func_continuous (f : ℝ → ℝ) := ∀ a : ℝ, func_continuous_at f a

-- Defintion composition of functions and sequences for sequential continuity
def func_seq_comp (f : ℝ → ℝ) (s : ℕ → ℝ) (n : ℕ) := f (s n)

-- Sequential continuity
lemma seq_contin_conv_lem {s : ℕ → ℝ} {a : ℝ} (h : ∀ n : ℕ, abs (s n - a) < 1 / (n + 1)) : s ⇒ a :=
begin
	intros ε hε,
	cases exists_nat_gt (1 / ε) with N₀ hN₀,
	let N : ℕ := max N₀ 1,
	have hN : 1 / ε < (N : ℝ) :=
		by {apply lt_of_lt_of_le hN₀,
		norm_cast, apply le_max_left
		},
	use N, intros n hn,
	apply lt_trans (h n),
	rw one_div_lt _ hε,
		{apply lt_trans hN,
		norm_cast, linarith},
		{norm_cast, linarith}
end	

theorem lambda_rw (n : ℕ) (f : ℕ → ℝ) : (λ x : ℕ, f x) n = f n := by {rw eq_self_iff_true, trivial}

theorem seq_contin {f : ℝ → ℝ} {a b : ℝ} : (func_converges_to f a b) ↔ ∀ s : ℕ → ℝ, s ⇒ a → func_seq_comp f s ⇒ b :=
begin
    split,
        {intros h s hs ε hε,
        rcases h ε hε with ⟨δ, ⟨hδ, hr⟩⟩,
        cases hs δ hδ with N hN,
        use N, intros n hn,
        have : abs (s n - a) < δ := hN n hn,
        from hr (s n) this
        },
        {intros h,
        cases classical.em (func_converges_to f a b) with ha ha,
        from ha,
        unfold func_converges_to at ha,
        push_neg at ha,
        rcases ha with ⟨ε, ⟨hε, hδ⟩⟩,
		have hα : ∀ n : ℕ, 1 / ((n : ℝ) + 1) > 0 := 
			by {intro n, simp,
			norm_cast, from nat.zero_lt_one_add n},
		have hβ : ∀ n : ℕ, ∃ (x : ℝ), abs (x - a) < (1 / (n + 1)) ∧ ε ≤ abs (f x - b) := λ n, hδ (1 / (n + 1)) (hα n),
        let s : ℕ → ℝ := λ n : ℕ, classical.some (hβ n),
		have h₀ : s  = λ n : ℕ, classical.some (hβ n) := rfl,
		have hsn : ∀ n : ℕ, abs (s n - a) < 1 / ((n : ℝ) + 1) ∧ ε ≤ abs (func_seq_comp f s n - b) :=
			by {intro n, rw [h₀, lambda_rw n s],
			from classical.some_spec (hβ n)
			},
		have h₁ : s ⇒ a := 
			by {have : ∀ n : ℕ, abs (s n - a) < 1 / ((n : ℝ) + 1) :=
				by {intro n, from (hsn n).left},
			from seq_contin_conv_lem this
			},
        have h₂ : ¬ (func_seq_comp f s ⇒ b) :=
            by {unfold converges_to,
            push_neg, use ε,
            split, from hε,
            intro N, use N,
            split, from nat.le_refl N,
			from (hsn N).right
            },
		exfalso; from h₂ (h s h₁)
        }
end

-- Algebra of limits for functions
def func_add_func (f g : ℝ → ℝ) := λ r : ℝ, f r + g r
instance : has_add (ℝ → ℝ) := ⟨func_add_func⟩


theorem func_add_func_conv (f g : ℝ → ℝ) (a b₁ b₂) : func_converges_to f a b₁ ∧ func_converges_to g a b₂ → func_converges_to (f + g) a (b₁ + b₂) :=
begin
	rintro ⟨ha, hb⟩,
	rw seq_contin,
	intros s hs,
	have : func_seq_comp (f + g) s = seq_add_seq (func_seq_comp f s) (func_seq_comp g s) := rfl,
	rw this,
	apply add_lim_conv,
	from ⟨seq_contin.mp ha s hs, seq_contin.mp hb s hs⟩
end

theorem func_add_func_contin (f g : ℝ → ℝ) : func_continuous f ∧ func_continuous g → func_continuous (f + g) :=
begin
	rintros ⟨ha, hb⟩ a,
	apply func_add_func_conv,
	from ⟨ha a, hb a⟩
end

def func_mul_func (f g : ℝ → ℝ) := λ r : ℝ, f r * g r
notation f ` × ` g := func_mul_func f g

theorem func_mul_func_conv (f g : ℝ → ℝ) (a b₁ b₂) : func_converges_to f a b₁ ∧ func_converges_to g a b₂ → func_converges_to (f × g) a (b₁ * b₂) :=
begin
	rintro ⟨ha, hb⟩,
	rw seq_contin,
	intros s hs,
	have : func_seq_comp (f × g) s = seq_mul_seq (func_seq_comp f s) (func_seq_comp g s) := rfl,
	rw this,
	apply mul_lim_conv,
	from seq_contin.mp ha s hs,
	from seq_contin.mp hb s hs,
end

theorem func_mul_func_contin (f g : ℝ → ℝ) : func_continuous f ∧ func_continuous g → func_continuous (f × g) :=
begin
	rintros ⟨ha, hb⟩ a,
	apply func_mul_func_conv,
	from ⟨ha a, hb a⟩
end

noncomputable def func_div_func (f g : ℝ → ℝ) := λ r : ℝ, (f r) / (g r)
notation f ` / ` g := func_div_func f g

theorem func_div_func_conv (f g : ℝ → ℝ) (a b₁ b₂) (h : b₂ ≠ 0) : func_converges_to f a b₁ ∧ func_converges_to g a b₂ → func_converges_to (f / g) a (b₁ / b₂) :=
begin
	rintro ⟨ha, hb⟩,
	rw seq_contin,
	intros s hs,
	have : func_seq_comp (f / g) s = seq_div_seq (func_seq_comp f s) (func_seq_comp g s) := rfl,
	rw this,
	apply div_lim_conv,
	from seq_contin.mp ha s hs,
	from seq_contin.mp hb s hs,
	norm_cast, assumption
end

theorem func_comp_func_conv (f g : ℝ → ℝ) (a b c : ℝ) : func_converges_to f a b ∧ func_converges_to g b c → func_converges_to (g ∘ f) a c :=
begin
	repeat {rw seq_contin},
	rintro ⟨ha, hb⟩,
	intros s hs,
	have : func_seq_comp (g ∘ f) s = func_seq_comp g (func_seq_comp f s) := rfl,
	rw this,
	apply hb (func_seq_comp f s),
	from ha s hs
end

theorem func_comp_func_contin (f g : ℝ → ℝ) : func_continuous f ∧ func_continuous g → func_continuous (g ∘ f) :=
begin
	repeat {unfold func_continuous},
	rintros ⟨ha, hb⟩ a,
	apply func_comp_func_conv,
	swap, from f a,
	from ⟨ha a, hb (f a)⟩
end

-- Starting to prove that all polynomials and rational functions are continuous

lemma constant_contin (c : ℝ) : func_continuous (λ x : ℝ, c) :=
begin
	intros a ε hε,
	simp, use ε,
	from ⟨hε, λ x, λ hx, hε⟩
end

lemma x_contin : func_continuous (λ x : ℝ, x) :=
begin
	intros a ε hε,
	simp, use ε,
	from ⟨hε, λ x, λ hx, hx⟩
end

lemma xn_contin (n : ℕ) : func_continuous (λ x : ℝ, x ^ n) :=
begin
	induction n with k hk,
		{simp, from constant_contin (1 : ℝ)},
		{have : (λ (x : ℝ), x ^ nat.succ k) = func_mul_func (λ x : ℝ, x) (λ x : ℝ, x ^ k) := rfl,
		rw this,
		apply func_mul_func_contin,
		from ⟨x_contin, hk⟩
		}
end

theorem poly_contin {f : polynomial ℝ} : func_continuous (λ x, f.eval x) :=
begin
	apply polynomial.induction_on f,
		{intro a, simp,
		from constant_contin a
		},
		{intros p q hp hq, simp, 
		apply func_add_func_contin (λ x : ℝ, polynomial.eval x p) (λ x : ℝ, polynomial.eval x q),
		from ⟨hp, hq⟩
		},
		simp,
		intros n a hcon,
		apply func_mul_func_contin,
		from ⟨constant_contin a, xn_contin (n + 1)⟩
end

-- Intermediate Value Theorem
theorem intermediate_value {f : ℝ → ℝ} {a b : ℝ} (h₀ : a ≤ b) (h₁ : func_continuous f) : ∀ y : ℝ, f a ≤ y ∧ y ≤ f b → ∃ c : ℝ, a ≤ c ∧ c ≤ b ∧ f c = y :=
begin
	rintros y ⟨hy₁, hy₂⟩,
	cases eq_or_lt_of_le hy₁ with heq hlt₀,
		{use a, split, linarith,
		rw heq, from ⟨h₀, refl y⟩
		},
		{cases eq_or_lt_of_le hy₂ with heq hlt₁,
			{use b, split, linarith,
			rw heq, from ⟨le_refl b, refl (f b)⟩
			},
		clear hy₁ hy₂,
		let S : set ℝ := {d : ℝ | a ≤ d ∧ d ≤ b ∧ f d < y},
		have hbdd : bounded_above S :=
			by {use b, intros s hs, 
			rw set.mem_set_of_eq at hs,
			from hs.right.left
			},
		have hnempty : S ≠ ∅ :=
			by {dsimp, rw set.not_eq_empty_iff_exists,
			use a, rw set.mem_set_of_eq,
			from ⟨le_refl a, h₀, hlt₀⟩
			},
		cases completeness S hbdd hnempty with M hM,
		use M, split,
			apply hM.left a,
			rw set.mem_set_of_eq,
			from ⟨le_refl a, h₀, hlt₀⟩,
		split,
			unfold sup at hM,
			have hα : upper_bound S b :=
				by {intros s hs,
				rw set.mem_set_of_eq at hs,
				from hs.right.left
				},
			cases le_or_lt M b with hβ hγ,
				from hβ,
				exfalso; from (hM.right b hγ) hα,
		rw le_antisymm_iff,
		split,
			{apply classical.by_contradiction,
			push_neg, intro h,
			have : ∃ ε : ℝ, ε = f M - y ∧ 0 < ε :=
				by {use f M - y,
				split, refl,
				linarith
				},
			cases this with ε hε,
			rcases h₁ M ε hε.right with ⟨δ, ⟨hδ, hhδ⟩⟩,
			rw hε.left at hhδ,
			have : ∀ (x : ℝ), abs (x - M) < δ → - (f M - y) < f x - f M ∧ f x - f M < f M - y :=
				by {intros x hx,
				apply abs_lt.mp,
				from hhδ x hx},
			simp at this,
			replace this : ∀ (x : ℝ), abs (x - M) < δ → x ∉ S :=
				by {intros x hx hS,
				rw set.mem_set_of_eq at hS,
				apply asymm (hS.right.right),
				from (this x hx).left
				},
			replace this : upper_bound S (M - δ) :=
				by {intros s hs,
				cases lt_or_le s (M - δ),
					{from le_of_lt h_1},
					{cases lt_or_eq_of_le h_1,
					swap, linarith,
					have hkt : abs (s - M) < δ :=
						by {rw abs_lt,
						split, linarith,
						rw sub_lt_iff_lt_add,
						apply lt_of_le_of_lt (hM.left s hs),
						linarith
						},
					exfalso,
					from (this s hkt) hs
					}
				},
			have hfa : M - δ < M :=
				by {linarith},
			from (hM.right (M - δ) hfa) this
			},

			{have hα : upper_bound S b :=
				by {intros s hs,
				rw set.mem_set_of_eq at hs,
				from hs.right.left
				},
			have hβ : M ≤ b := by {rw ←not_lt, intro hγ, from hM.right b hγ hα},
			cases lt_or_eq_of_le hβ,
			swap, rw h, from le_of_lt hlt₁,

			apply classical.by_contradiction,
			push_neg, intro h,
			have : ∃ ε : ℝ, ε = y - f M ∧ 0 < ε :=
				by {use y - f M,
				split, refl,
				linarith
				},
			cases this with ε hε,
			rcases h₁ M ε hε.right with ⟨δ, ⟨hδ, hhδ⟩⟩,
			rw hε.left at hhδ,
			have : abs (M + (δ / 2) - M) < δ := 
				by {simp,
				rw abs_of_pos (half_pos hδ),
				linarith
				},
			replace this : abs (M + min (δ / 2) ((b - M) / 2) - M) < δ := 
				by {apply lt_of_le_of_lt _ this,
				rw add_comm, simp,
				have hpos : 0 < min (δ / 2) ((b + -M) / 2) :=
					by {simp, split,
					from half_pos hδ,
					linarith
					},
				rw [abs_of_pos hpos, abs_of_pos (half_pos hδ)],
				from min_le_left (δ / 2) ((b - M) / 2),
				},
			replace this : abs (f (M + min (δ / 2) ((b - M) / 2)) - f M) < y - f M :=
				by {from hhδ (M + min (δ / 2) ((b - M) / 2)) this},
			rw abs_lt at this,
			cases this with h₃ h₄,
			simp at h₄,
			have h₅ : M < M + min (δ / 2) ((b + -M) / 2) :=
				by {simp, split,
				from half_pos hδ,
				linarith
				},
			have h₆ : M + min (δ / 2) ((b + -M) / 2) ∈ S :=
				by {rw set.mem_set_of_eq,
				split, apply le_of_lt (lt_of_le_of_lt _ h₅),
				have : a ∈ S := by {rw set.mem_set_of_eq, from ⟨le_refl a, h₀, hlt₀⟩},
				from hM.left a this,
				split,
				cases le_or_lt (δ / 2) ((b + -M) / 2),
					rw min_eq_left h_1,
					suffices : (δ / 2) < b + -M, linarith,
					apply lt_of_le_of_lt h_1, linarith,
					rw min_eq_right (le_of_lt h_1),
					linarith,
					from h₄
				},
			have h₇ : ¬ upper_bound S M :=
				by {unfold upper_bound,
				push_neg, 
				use (M + min (δ / 2) ((b + -M) / 2)),
				from ⟨h₆, h₅⟩
				},
			from h₇ hM.left
			}
		}
end

def func_bounded_above {S : set ℝ} (f : S → ℝ) := bounded_above {t : ℝ | ∀ x : S, t = f x}
def func_bounded_below {S : set ℝ} (f : S → ℝ) := bounded_below {t : ℝ | ∀ x : S, t = f x}

-- TODO Extreme value theorem

def closed_interval (a b : ℝ) := {x : ℝ | a ≤ x ∧ x ≤ b}
def open_interval (a b : ℝ) := {x : ℝ | a < x ∧ x < b}

def is_open (S : set ℝ) := ∀ x ∈ S, ∃ δ > 0, open_interval (x - δ) (x + δ) ⊆ S

-- An open interval is open
theorem open_interval_is_open {a b : ℝ} : is_open (open_interval a b) :=
begin
	unfold open_interval,
	intros x hx,
	have hδ : 0 < min (x - a) (b - x) :=
		by {apply lt_min_iff.mpr,
		rw set.mem_set_of_eq at hx,
		cases hx with ha hb,
		split, repeat {linarith},
		},
	use min (x - a) (b - x), use hδ,
	unfold open_interval,
	intros y hy,
	rw set.mem_set_of_eq at hy,
	rw set.mem_set_of_eq,
	cases hy with hy₁ hy₂,
	split,
		{apply lt_of_le_of_lt _ hy₁,
		have : min (x - a) (b - x) ≤ x - a := min_le_left (x - a) (b - x),
		linarith
		},
		{apply lt_of_lt_of_le hy₂,
		have : min (x - a) (b - x) ≤ b - x := min_le_right (x - a) (b - x),
		linarith
		}
end

end M40002
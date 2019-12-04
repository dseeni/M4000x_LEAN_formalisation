import M40001.M40001_4
import data.equiv.basic

namespace M40001

def tricky (X : Type*) : {R : bin_rel X | equivalence R} ≃ {A : set (set X) | partition A} :=
{ to_fun := λ r, ⟨{a : set X | ∃ s : X, a = cls r.1 s}, equiv_relation_partition r.1 r.2⟩,
  inv_fun := λ a, ⟨rs a.1, partition_equiv_relation a.1 a.2 ⟩,
  left_inv := 
begin
    unfold function.left_inverse,
    intro r,
    rcases r.2 with ⟨rrefl, ⟨rsymm, rtran⟩⟩,
    sorry
end,
  right_inv := 
begin
  unfold function.right_inverse,
  unfold function.left_inverse,
  intro b,
  unfold cls,
  sorry
end
}

end M40001
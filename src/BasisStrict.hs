module BasisStrict where

import           Data.Complex (Complex, magnitude)
import           Data.Map     (Map, elems, fromList, lookup)
import           Data.Maybe   (fromMaybe)
import           Prelude      hiding (lookup)

-- | A class 'Basis' that defines an abstract representation for a basis set.
--   The types that are instances of this class represent possible basis vectors
--   that can be used in quantum vector spaces.
class (Eq a, Ord a) =>
      Basis a
  -- | 'basis' is a list of possible values or "basis vectors" for the type 'a'.
  where
  basis :: [a]

-- | The 'Move' data type represents two possible movements: Vertical and Horizontal.
data Move
  = Vertical
  | Horizontal
  deriving (Eq, Ord, Show)

-- | The 'Rotation' data type represents two possible rotations:
--   Counter-clockwise ('CtrClockwise') and 'Clockwise'.
data Rotation
  = CtrClockwise
  | Clockwise
  deriving (Eq, Ord, Show)

-- | The 'Colour' data type represents three colours: 'Red', 'Yellow', and 'Blue'.
data Colour
  = Red
  | Yellow
  | Blue
  deriving (Eq, Ord, Show)

instance Basis Bool where
  basis = [False, True]

instance Basis Move where
  basis = [Vertical, Horizontal]

instance Basis Rotation where
  basis = [CtrClockwise, Clockwise]

instance Basis Colour where
  basis = [Red, Yellow, Blue]

-- | Type alias 'PA' representing a **probability amplitude**, which is
--   a complex number.
type PA = Complex Double

-- | 'QV' is a type alias for a **quantum vector space** (represented by a map).
--   The map keys are basis vectors (of type 'a') and the values are complex
--   probability amplitudes of type 'PA'.
type QV a = Map a PA

-- | 'isNormalized' checks if a quantum vector is normalized.
--   A normalized vector must have the sum of squared magnitudes of its
--   probability amplitudes equal to 1 (within a small tolerance).
--   The check stops after examining up to 1000 elements, allowing for
--   the theoretical model to support an infinite number of elements.
--
--   Parameters:
--   - A Map of keys 'a' and probability amplitudes 'PA'
--
--   Returns:
--   - 'Bool': 'True' if the vector is normalized, otherwise 'False'
isNormalized :: (Ord a) => Map a PA -> Bool
isNormalized m =
  abs (sum (map ((^ (2 :: Int)) . magnitude) (elems m)) - 1) < 1e-9

-- | 'qVector' constructs a **normalized quantum vector** ('QV') from a Map of
--   basis vector-amplitude pairs. It ensures the vector is normalized.
--
--   Parameters:
--   - Map of pairs @Map a PA@, where 'a' is the basis vector and 'PA' is
--     the probability amplitude (a complex number)
--
--   Returns:
--   - @QV a@: a quantum vector, represented as an association list of
--     basis vectors and probability amplitudes
--
--   Throws:
--   - An 'error' with the message *"The quantum vector is not normalized."*
--     if the sum of squared magnitudes of the probability amplitudes does not equal 1.
qVector :: Basis a => [(a, PA)] -> QV a
qVector qv
  | (isNormalized . fromList) qv = fromList qv
  | otherwise = error "The quantum vector is not normalized."

-- | 'amplitude' returns the **probability amplitude** associated with a
--   given unit vector in the quantum vector.
--
--   Parameters:
--   - @Map a PA@: a quantum vector represented as a map
--     of basis vectors and probability amplitudes
--   - 'a': the basis vector for which to retrieve the amplitude
--
--   Returns:
--   - 'PA': the probability amplitude associated with the basis vector,
--     or 0 if not found
amplitude :: Basis a => QV a -> a -> PA
amplitude qvs k = fromMaybe 0 (lookup k qvs)
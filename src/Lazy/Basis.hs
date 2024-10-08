{-|
This module defines the 'Basis' class and its instances, which represent
the possible basis vectors for various types that can be used in quantum
vector spaces.

Note that due to the lazy nature of the implementation, this module does
not enforce uniqueness checks for the elements in the basis. Consequently,
instances of the 'Basis' class can contain duplicate elements. It is the
responsibility of the user to ensure that the basis is free of duplicates
where necessary.
-}
module Lazy.Basis where

import           Data.Complex (Complex, magnitude)
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

-- | Type alias 'PA' representing a __probability amplitude__, which is
--   a complex number.
type PA = Complex Double

-- | 'AssocList' represents an association list of key-value pairs. It's
--   used instead of 'Map' due to its laziness, which is not guaranteed by 'Map'.
type AssocList k v = [(k, v)]

-- | 'QV' is a type alias for a __quantum vector space__ (represented by a map).
--   The map keys are basis vectors (of type 'a') and the values are complex
--   probability amplitudes of type 'PA'.
type QV a = AssocList a PA

-- | 'lookup' searches for a key in an 'AssocList'.
--   If the key is found, it returns 'Just' the associated value,
--   otherwise it returns 'Nothing'.
--
--   __Parameters:__
--
--   - 'key': the key of type 'k' to search for
--   - @AssocList k v@: an association list of key-value pairs
--
--   __Returns:__
--
--   - @Maybe v@: the value associated with the key, or 'Nothing' if not found
lookup :: Eq k => k -> AssocList k v -> Maybe v
lookup _ [] = Nothing
lookup key ((k, v):xs)
  | key == k = Just v
  | otherwise = lookup key xs

-- | 'qVector' constructs a __unnormalized quantum vector__ ('QV') from a list of
--   basis vector-amplitude pairs. It ensures the vector is normalized.
--
--   __Parameters:__
--
--   - A list of pairs @(a, PA)@, where 'a' is the basis vector and 'PA' is
--     the probability amplitude (a complex number)
--
--   __Returns:__
--
--   - @QV a@: a quantum vector, represented as an association list of
--     basis vectors and probability amplitudes
qVector :: Basis a => [(a, PA)] -> QV a
qVector = id

-- | 'isNormalized' checks if a quantum vector is normalized.
--   A normalized vector must have the sum of squared magnitudes of its
--   probability amplitudes equal to 1 (within a small tolerance).
--   The check stops after examining up to 1000 elements, allowing for
--   the theoretical model to support an infinite number of elements.
--
--   __Parameters:__
--
--   - A list of pairs @(a, PA)@, where 'a' is the basis vector and 'PA' is
--     the probability amplitude (a complex number)
--
--   __Returns:__
--
--   - 'Bool': 'True' if the vector is normalized, otherwise 'False'
isNormalized :: Basis a => [(a, PA)] -> Bool
isNormalized = go 0 1000
  where
    go :: Basis a => Double -> Int -> [(a, PA)] -> Bool
    go acc 0 _ = abs acc > 1 - 1e-9
    go acc _ [] = acc > 1 - 1e-9
    go acc n ((_, amp):xs)
      | acc > 1 + 1e-9 = False
      | otherwise = go (acc + magnitude amp ^ (2 :: Int)) (n - 1) xs

-- | 'qVector'' constructs a __normalized quantum vector__ ('QV') from a list of
--   basis vector-amplitude pairs. It ensures the vector is normalized.
--
--   __Parameters:__
--
--   - A list of pairs @(a, PA)@, where 'a' is the basis vector and 'PA' is
--     the probability amplitude (a complex number)
--
--   __Returns:__
--
--   - @QV a@: a quantum vector, represented as an association list of
--     basis vectors and probability amplitudes
--
--   __Throws:__
--
--   - An 'error' with the message *"The quantum vector is not normalized."*
--     if the sum of squared magnitudes of the probability amplitudes does not equal 1.
qVector' :: Basis a => [(a, PA)] -> QV a
qVector' qv
  | isNormalized qv = qv
  | otherwise = error "The quantum vector is not normalized."

-- | 'amplitude' returns the __probability amplitude__ associated with a
--   given unit vector in the quantum vector.
--
--   __Parameters:__
--
--   - @AssocList a PA@: a quantum vector represented as an association list
--     of basis vectors and probability amplitudes
--   - 'a': the basis vector for which to retrieve the amplitude
--
--   __Returns:__
--
--   - 'PA': the probability amplitude associated with the basis vector,
--     or 0 if not found
amplitude :: Basis a => AssocList a PA -> a -> PA
amplitude qvs k = fromMaybe 0 (lookup k qvs)

instance Basis Integer where
  basis = [0 ..]

-- | 'qInteger' represents an infinite quantum vector for 'Integer',
--   where the amplitude for each integer is given by the reciprocal of
--   the square root of 2 raised to the power of the integer (except for 0).
--
--   __Returns:__
--
--   - @QV Integer@: an infinite quantum vector for 'Integer', represented
--     as an association list of integers and probability amplitudes
qInteger :: QV Integer
qInteger = qVector' [(i, 1 / sqrt (2 ^ i)) | i <- tail basis]

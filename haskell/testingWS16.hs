elem1 :: Eq a => a -> [a] -> Bool
elem1 x = not . null . filter (==x)

elem2 :: Eq a => a -> [a] -> Bool
elem2 x = foldr ((||) . (==x)) False

elem3 :: Eq a => a -> [a] -> Bool
elem3 x = foldl (flip ((||) . (==x))) False

-- elem2 ist effizienter
-- elem2 nutzt foldr und kann damit von der verkürzten Auswertung profitieren, foldl nicht.

filter1 :: (a -> Bool) -> [a] -> [a]
filter1 f = foldr (\ x rs -> if f x then x : rs else rs) []

data T a = T0 a
         | T1 Op1 (T a)
         | T2 Op2 (T a) (T a)
         deriving Show

data Op1 = U1 | U2 | U3 deriving (Eq, Show)

data Op2 = B1 | B2 | B3 deriving (Eq, Show)

instance Eq a => Eq (T a) where
  (==) = eqT

eqT :: Eq a => T a -> T a -> Bool
eqT (T0 a) (T0 b)                   = a == b
eqT (T1 o1 t1) (T1 o2 t2)           = o1 == o2 && eqT t1 t2
eqT (T2 o1 t11 t12) (T2 o2 t21 t22) = o1 == o2 && eqT t11 t21 && eqT t12 t22
eqT _ _                             = False

instance Functor T where
  fmap = mapT

mapT :: (a -> b) -> T a -> T b
mapT f (T0 a)       = T0 (f a)
mapT f (T1 o t)     = T1 o (mapT f t)
mapT f (T2 o t1 t2) = T2 o (mapT f t1) (mapT f t2)

zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' f (a:as) (b:bs) = (f a b) : zipWith' f as bs
zipWith' _ _ _           = []

data Tree a = Nil
            | Fork a (Tree a) (Tree a)
            deriving Show

zipTreeWith :: (a -> b -> c) -> Tree a -> Tree b -> Tree c
zipTreeWith f = go
  where
    go (Fork a ta1 ta2) (Fork b tb1 tb2) = Fork (f a b) (go ta1 tb1) (go ta2 tb2)
    go _ _                               = Nil


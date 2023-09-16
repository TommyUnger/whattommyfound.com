import unittest
from ..data_sources.fec import Fec

class TestFec(unittest.TestCase):

    def test_cm_cn_get(self):
        fec = Fec()
        fec.cm_cn_get("cm", "committee", "https://www.fec.gov/files/bulk-downloads/1980/cm80.zip", "committee80")
        # self.assertEqual('foo'.upper(), 'FOO')


if __name__ == '__main__':
    unittest.main()
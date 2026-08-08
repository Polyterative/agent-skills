import unittest
from report import process


class TestReport(unittest.TestCase):
    def test_happy_path(self):
        out = process(["apple,2,1.50", "banana,3,0.50", "apple,1,1.50"])
        self.assertEqual(out, "apple: 4.50\nbanana: 1.50")

    def test_comments_and_blanks(self):
        out = process(["# header", "", "apple,1,2.00"])
        self.assertEqual(out, "apple: 2.00")

    def test_errors_counted(self):
        out = process(["bad line", "apple,x,1", ",1,1", "apple,-1,1", "apple,1,2.00"])
        self.assertEqual(out, "apple: 2.00\nerrors: 4")

    def test_only_errors(self):
        self.assertEqual(process(["nope"]), "errors: 1")

    def test_empty(self):
        self.assertEqual(process([]), "")


if __name__ == "__main__":
    unittest.main()

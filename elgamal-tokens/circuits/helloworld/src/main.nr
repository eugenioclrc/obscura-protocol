fn main(x: Field, y: pub Field) -> pub Field {
    assert(x == y);
    y
}

#[test]
fn test_equal_values() {
    let x = 5;
    let y = 5;
    let result = main(x, y);
    assert(result == y);
}

#[test(should_fail)]
fn test_different_values() {
    let x = 5;
    let y = 6;
    assert(main(x, y) == y);
}


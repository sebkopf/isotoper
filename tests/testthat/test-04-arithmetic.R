context("Data Operations")

# FIXME: merge with 03-conversions for more consistent testing

test_that("Testing proper response to math operators", {
    # operations that are not meaningful ===========
    expect_is(r <- ratio(0.1), "Ratio")
    expect_is(i <- intensity(100), "Intensity")
    expect_is(rs <- ratio(0.1, 0.2), "Ratios")
    expect_is(is <- intensity(100, 1000), "Intensities")
    expect_error(r + 5, "Addition .* not meaningful")
    expect_error(5 + r, "Addition .* not meaningful")
    expect_error(r + i, "Addition .* not meaningful")
    expect_error(r + is, "Addition .* not meaningful")
    expect_error(rs + is, "Addition .* not meaningful")
    expect_error(r - 5, "Subtraction .* not meaningful")
    expect_error(5 - r, "Subtraction .* not meaningful")
    expect_error(r - i, "Subtraction .* not meaningful")
    expect_error(r - is, "Subtraction .* not meaningful")
    expect_error(rs - is, "Subtraction .* not meaningful")
    expect_error(r * 5, "Multiplication .* not meaningful")
    expect_error(5 * r, "Multiplication .* not meaningful")
    expect_error(r * i, "Multiplication .* not meaningful")
    expect_error(r * is, "Multiplication .* not meaningful")
    expect_error(rs * is, "Multiplication .* not meaningful")
    expect_error(r / 5, "Division .* not meaningful")
    expect_error(5 / r, "Division .* not meaningful")
    expect_error(r / i, "Division .* not meaningful")
    expect_error(r / is, "Division .* not meaningful")
    expect_error(rs / is, "Division .* not meaningful")
    
    # operations that are permitted and implemented ===========
    
    # converting intensity to ratio 
    expect_error(intensity(100, unit = "mV") / intensity(1000), "cannot generate an isotope ratio from two intensity objects")
    expect_error(intensity(100, unit = "mV") / intensity(1000, unit = "V"), "cannot generate an isotope ratio from two intensity objects")
    expect_error(intensity(1:5) / intensity(2:3), "cannot generate an isotope ratio from two intensity objects that don't have matching lengths")
    expect_is(r <- intensity(`13C` = 1:5) / intensity(`12C` = 5:9), "Ratio")
    expect_equal(as.numeric(r), 1:5/5:9)
    expect_equal(r@isoname, "13C")
    expect_equal(r@major, "12C")
    
    # converting ratios to alpha values - FIXME
    expect_error(ratio(a = 0.1) / ratio(b = 0.2), "cannot generate a fractionaton factor from two ratio objects that don't have matching attributes")
    expect_error(ratio(0.1, major = "12C") / ratio(`15N`=0.2), "cannot generate a fractionaton factor from two ratio objects that don't have matching attributes")
    expect_equal(ratio(0.1) / ratio(0.2), ff(0.5))
    expect_equal(to_ff(ratio(0.1), ratio(0.2)), ff(0.5))
    expect_equal(a <- ratio(`13C` = 0.1, major = "12C", compound = "CO2") / ratio(`13C` = 0.2, major = "12C", compound = "Corg"), 
                 ff(`13C` = 0.5, major = "12C", ctop = "CO2", cbot = "Corg"))
    
    # converting ff * ratio to ratio
    expect_error(ff(a = 0.5) * ratio(b = 0.1), "cannot generate a ratio from a fractionation factor and a ratio")
    expect_error(ff(0.5, major = "12C") * ratio(0.1, major = "13C"), "cannot generate a ratio from a fractionation factor and a ratio")
    expect_error(ff(0.5, cbot = "Corg") * ratio(0.4, compound = "CO2"), "cannot generate a ratio .* denominator .* not match .* compound")
    expect_equal(a * ratio(`13C` = 0.4, major = "12C", compound = "Corg"), ratio(`13C` = 0.2, major = "12C", compound = "CO2"))
    expect_equal(get_weight(weight(ff(0.9), 2) * ratio(0.2, weight = 3)), 3) # keeping weight of ratio
    expect_equal(get_weight(ratio(0.2, weight = 3) * ff(0.9)), 3) # keeping weight of ratio
    
    # converting alpha * alpha to alpha
    expect_error(ff(a = 0.8) * ff(b = 0.9), "cannot generate a fractionation factor from two fractionation factors that don't have matching attributes")
    expect_error(ff(0.8, major = "12C") * ff(0.9, major = "13C"), "cannot generate a fractionation factor from two fractionation factors that don't have matching attributes")
    expect_error(ff(0.8, cbot = "Corg") * ff(0.9, ctop = "CO2"), "cannot combine two fractionation factors if their denominator .* numerator .* don't cancel")
    expect_equal(ff(0.8, ctop = "CO2", cbot = "DIC") * ff(0.9, ctop = "DIC", cbot = "Corg"), ff(0.8*0.9, ctop = "CO2", cbot = "Corg"))
    expect_equal(ff(0.8, ctop = "CO2", cbot = "DIC", notation = "alpha") * ff(-100, ctop = "DIC", cbot = "Corg", notation = "permil"), ff(0.8*0.9, ctop = "CO2", cbot = "Corg"))
    
    # converting alpha * delta to delta (fractionate it)
    expect_error(ff(a = 0.8) * delta(b = 0.9), "cannot generate a fractionation factor from two fractionation factors that don't have matching attributes")
    expect_equal(ff(0.8) * delta(200), delta((0.8*1.2 - 1)*1000))
    expect_equal(ff(0.8) * delta(0.2, notation = "raw"), delta(0.8*1.2 - 1, notation = "raw"))
    expect_equal(ff(0.8) * delta(200), fractionate(ff(0.8), delta(200))) # test actual fractionate function does the same

    # converting alpha / alpha to alpha
    expect_error(ff(a = 0.8) / ff(b = 0.9), "cannot generate a fractionation factor from two fractionation factors that don't have matching attributes")
    expect_error(ff(0.8, ctop = "CO2", cbot = "Corg") / ff(0.9, ctop = "Corg", cbot = "CO2"), "cannot combine two fractionation factors if neither their denominators .* numerators .* cancel")
    expect_equal(ff(0.8, ctop = "CO2", cbot = "DIC") / ff(0.9, ctop = "Corg", cbot = "DIC"), ff(0.8/0.9, ctop = "CO2", cbot = "Corg"))
    expect_equal(ff(0.8, ctop = "DIC", cbot = "CO2") / ff(0.9, ctop = "DIC", cbot = "Corg"), ff(0.8/0.9, ctop = "Corg", cbot = "CO2"))
    
    # convert alpha - 1 = epsilon
    expect_equal(eps <- ff(0.99, notation = "alpha") - 1, ff(-0.01, notation = "eps")) # exception to allow the math of this
    expect_equal(eps + 1, ff(0.99, notation = "alpha"))
    expect_error(ff(0.99) - 2, "Subtraction is not meaningful")
#     
    # convert deltas to alpha (with delta/delta)
    expect_equal(delta(200) / delta(-200), ff(1.2 / 0.8))
    expect_equal(delta(200) / delta(-200), to_ff(delta(200), delta(-200)))
    
    # shift refrence frame
    expect_equal(get_value(delta(200) * delta(-200)), (1.2 * 0.8 - 1) * 1000) # formula test
    expect_equal(delta(200) * delta(-200), shift_reference(delta(200), delta(-200))) # actual function equivalent to arithmetic
    expect_error(delta(200, ref = "CO2") * delta(-200, compound = "DIC"),"cannot combine two fractionation factors .* denominator .* numerator .* don't cancel")
 
    # FIXME objects are equal but not identical, why not?
#    expect_equal(delta(200, compound = "CO2", ref = "internal") * delta(-200, compound = "internal", ref = "SMOW", ref_ratio = 0.1), 
#                 delta(-40, compound = "CO2", ref = "SMOW", ref_ratio = 0.1))
    
    # combining intensities with same definition
    expect_error(intensity(a = 100) + intensity(b = 1000), "trying to combine two intensity objects that don't have matching attributes")
    expect_error(intensity(1:5) + intensity(1000), "trying to combine two intensity objects that don't have matching lengths")
    expect_is(ci <- intensity(100) + intensity(1000), "Intensity")
    expect_is(ci <- intensity(a = 100, major = "b", unit = "mV") + intensity(a = 1000, major = "b", unit = "mV"), "Intensity")
    expect_equal(get_value(ci), 1100.)
    expect_equal(ci@isoname, "a")
    expect_equal(ci@major, "b")
    expect_equal(ci@unit, "mV")
    expect_is(ci <- intensity(1000) - intensity(500), "Intensity")
    expect_equal(get_value(ci), 500.)
    

    # mixing abundances
    expect_error(abundance(a = 0.2) + abundance(b = 0.3), "trying to calculate the mass balance of two abundance objects that don't have matching attributes")
    expect_is(amix <- abundance(0.2) + abundance(0.4), "Abundance")
    expect_equal(get_value(amix), 0.3)
    expect_equal(get_weight(amix), 2)
    expect_equal(get_weighted_value(amix), 0.6)
    expect_equal(amix@compound, "")
    expect_is(amix <- abundance(0.2) + abundance(0.4, compound = "b"), "Abundance")
    expect_equal(amix@compound, "?+b")
    expect_is({
        amix <- abundance(`13C` = 0.2, weight = 2, compound = "a") + 
            abundance(`13C` = 0.5, compound = "b") + 
            abundance(`13C` = 0.3, weight = 3, compound = "c")}, "Abundance")
    expect_equal(get_label(amix), "a+b+c F 13C") # compound name propagation
    expect_equal(get_value(amix), (0.2*2 + 0.5 + 0.3*3) / (2+1+3)) # formula test
    expect_equal(get_weight(amix), (2+1+3)) # formula test
    expect_equal(get_weighted_value(amix), (0.2*2 + 0.5 + 0.3*3)) # formula test
    expect_is(ab <- abundance(0.4, weight = 10) - abundance(0.04, weight = 1), "Abundance") # removing material from a reservoir
    expect_error(abundance(0.1) - abundance(0.1), "not a valid isotope")
    expect_error(abundance(0.9, weight = 2) - abundance(0.1), "abundances cannot be larger than 1")
    expect_equal(abundance(0.2) + abundance(0.4) + abundance(0.6), mass_balance(abundance(0.2), abundance(0.4), abundance(0.6))) 
    
    # inverting weight
    expect_equal( (-abundance(0.2))@weight, -1)
    expect_equal( (-abundance(0.2, weight=5))@weight, -5)
    
    # mixing ratios (currently not allowed, only abundances and delta values!)
    expect_error(ratio(a = 0.2) + ratio(b = 0.3), "not meaningful for these isotope objects")
    #     expect_error(ratio(a = 0.2) + ratio(b = 0.3), "trying to mix two isotope objects that don't have matching attributes")
    #     expect_error(ratio(c(0.1, 0.2)) + ratio(0.3), "trying to mix two isotope objects that don't have matching lengths")
    #     expect_is(rmix <- to_ratio(abundance(0.2)) + to_ratio(abundance(0.4)), "Ratio")
    #     expect_equal(get_value(rmix), get_value(to_ratio(abundance(0.3))))
    #     expect_equal(get_weight(rmix), 2)
    #     expect_error(ratio(0.2, 0.3) + ratio(0.3, 0.4), "this really needs to be implemented") # FIXME
    
    # mixing delta values
    expect_error(delta(a = 200) + delta(b = -300), "trying to calculate the mass balance of two delta values that don't have matching attributes")
    expect_error(delta(c(100, 200)) + delta(-300), "trying to calculate the mass balance of two delta values that don't have matching lengths")
    expect_is(amix <- delta(200) + delta(-300), "Delta")
    expect_equal(get_value(amix), -50)
    expect_equal(get_weight(amix), 2)
    expect_equal(get_weighted_value(amix), -100)
    expect_equal(amix@compound, "")
    expect_is(amix <- delta(200) + delta(-300, compound = "b"), "Delta")
    expect_equal(amix@compound, "?+b")
    expect_is({
        amix <- delta(`13C` = 200, weight = 2, compound = "a") + 
            delta(`13C` = 0.5, compound = "b") + 
            delta(`13C` = -300, weight = 3, compound = "c")}, "Delta")
    expect_equal(get_label(amix), paste0("a+b+c ", get_iso_letter("delta"), "13C [", get_iso_letter("permil"), "]")) # compound name propagation
    expect_equal(get_value(amix), (200*2 + 0.5 + -300*3) / (2+1+3)) # formula test
    expect_equal(get_weight(amix), (2+1+3)) # formula test
    expect_equal(get_weighted_value(amix), (200*2 + 0.5 + -300*3)) # formula test
    expect_is(ab <- delta(0.4, weight = 10) - delta(0.04, weight = 1), "Delta") # removing material from a reservoir

    expect_error(mass_balance(delta(100), delta(200), exact = TRUE), "not implemented yet")
    expect_error(mass_balance(delta(100, 200), delta(200, 200), exact = TRUE), "not implemented yet")
})

# INFO: test-03-conversions holds the arithmetic notation tests

test_that("Testing more complex computation", {
    #FIXME
#     expect_equal(alpha(0.8) * delta(500) + delta(100), 
#                  to_delta(delta( (0.8*1.5 - 1 + 0.1)/2, compound = "?+?", weight=2, permil = F)))
    
    register_standard(ratio(`13C` = 0.011237, major = "12C", compound = "VPDB"))
#    expect_is(to_abundance(delta(`13C` = alpha(0.8) * delta(500) + delta(100) - alpha(0.9) * delta(300), major = "12C", ref = "VPDB")), "Abundance")
    # FIXME continue
    
})

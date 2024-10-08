package risc_zero

/*
#cgo linux LDFLAGS: ${SRCDIR}/lib/librisc_zero_verifier_ffi.so -ldl -lrt -lm -lssl -lcrypto -Wl,--allow-multiple-definition
#cgo darwin LDFLAGS: -L./lib -lrisc_zero_verifier_ffi

#include "lib/risc_zero.h"
*/
import "C"
import (
	"unsafe"
)

func VerifyRiscZeroReceipt(innerReceiptBuffer []byte, innerReceiptLen uint32, imageIdBuffer []byte, imageIdLen uint32, publicInput []byte, publicInputLen uint32) bool {
	if len(innerReceiptBuffer) == 0 || len(imageIdBuffer) == 0 {
		return false
	}

	receiptPtr := (*C.uchar)(unsafe.Pointer(&innerReceiptBuffer[0]))
	imageIdPtr := (*C.uchar)(unsafe.Pointer(&imageIdBuffer[0]))

	if len(publicInput) == 0 { // allow empty public input
		return (bool)(C.verify_risc_zero_receipt_ffi(receiptPtr, (C.uint32_t)(innerReceiptLen), imageIdPtr, (C.uint32_t)(imageIdLen), nil, (C.uint32_t)(0)))
	}

	publicInputPtr := (*C.uchar)(unsafe.Pointer(&publicInput[0]))
	return (bool)(C.verify_risc_zero_receipt_ffi(receiptPtr, (C.uint32_t)(innerReceiptLen), imageIdPtr, (C.uint32_t)(imageIdLen), publicInputPtr, (C.uint32_t)(publicInputLen)))
}

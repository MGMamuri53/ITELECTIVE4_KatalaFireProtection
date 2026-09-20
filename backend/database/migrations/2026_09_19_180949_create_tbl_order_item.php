<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_orderItem', function (Blueprint $table) {
            $table->bigIncrements('v_orderItemId');

            $table->unsignedBigInteger('v_orderId');
            $table->unsignedBigInteger('v_productId');

            $table->string('v_productNameSnapshot', 150)
                ->nullable();

            $table->decimal('v_quantity', 14, 2);

            $table->decimal('v_unitPrice', 14, 2);

            $table->decimal('v_discountAmount', 14, 2)
                ->default(0.00);

            $table->decimal('v_lineAmount', 14, 2)
            ->storedAs(
                '("v_quantity" * "v_unitPrice") - "v_discountAmount"'
            );

            $table->text('v_notes')
                ->nullable();

            $table->foreign('v_orderId', 'fk_orderItem_order')
                ->references('v_orderId')
                ->on('tbl_order')
                ->onUpdate('cascade')
                ->onDelete('cascade');

            $table->foreign('v_productId', 'fk_orderItem_product')
                ->references('v_productId')
                ->on('tbl_product')
                ->onUpdate('cascade')
                ->onDelete('restrict');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_orderItem');
    }
};
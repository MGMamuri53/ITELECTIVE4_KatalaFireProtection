<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_warranty', function (Blueprint $table) {
            $table->bigIncrements('v_warrantyId');

            $table->string('v_warrantyNumber', 60)
                ->nullable()
                ->unique();

            $table->unsignedBigInteger('v_customerId');

            $table->unsignedBigInteger('v_orderId')
                ->nullable();

            $table->unsignedBigInteger('v_projectId')
                ->nullable();

            $table->unsignedBigInteger('v_productId')
                ->nullable();

            $table->string('v_warrantyType', 50)
                ->nullable();

            $table->dateTime('v_startDate')
                ->nullable();

            $table->dateTime('v_endDate')
                ->nullable();

            $table->text('v_coverageDetails')
                ->nullable();

            $table->text('v_termsAndConditions')
                ->nullable();

            $table->string('v_warrantyStatus', 50)
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign(
                'v_customerId',
                'fk_warranty_customer'
            )
                ->references('v_customerId')
                ->on('tbl_customer')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign(
                'v_orderId',
                'fk_warranty_order'
            )
                ->references('v_orderId')
                ->on('tbl_order')
                ->onUpdate('cascade')
                ->onDelete('set null');

            $table->foreign(
                'v_projectId',
                'fk_warranty_project'
            )
                ->references('v_projectId')
                ->on('tbl_project')
                ->onUpdate('cascade')
                ->onDelete('set null');

            $table->foreign(
                'v_productId',
                'fk_warranty_product'
            )
                ->references('v_productId')
                ->on('tbl_product')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_warranty');
    }
};